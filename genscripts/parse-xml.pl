#!/usr/bin/env perl
# Parse the .xml file created by this:
#   castxml --castxml-gccxml --castxml-cc-gnu-c /usr/bin/gcc -o genscripts/rdkafka-0.9.2.xml genscripts/rdkafka-0.9.2.h
#
# where the .h file is a copy of rdkafka.h from a particular version of librdkafka.
# (The parsing depends on the location being the "genscripts/" directory.)
use strict;
use warnings;
use Data::Dumper; { package Data::Dumper; our ($Indent, $Sortkeys, $Terse, $Useqq) = (1)x4 }

use XML::LibXML;

$|++;
main();
exit;

sub main {
    my $root = root_node();

    my @top_nodes = top_nodes_from_header_file($root);
    my $nodes_by_id = nodes_by_id($root);

    process_top_nodes(\@top_nodes, $nodes_by_id);
}

sub root_node {
    my $doc = XML::LibXML->load_xml(IO => *STDIN);
    my $root = $doc->documentElement();
    return($root);
}

sub nodes_by_id {
    my ($node) = @_;
    my @id_nodes = nodes_with_id($node);

    my %nodes_by_id;
    foreach my $id_node (@id_nodes) {
        my $id = $id_node->getAttribute('id');
        $nodes_by_id{$id} = $id_node;
    }
    return \%nodes_by_id;
}

sub nodes_with_id {
    my ($node) = @_;

    my @id_nodes;
    if (my @child = child_element_nodes($node)) {
        push(@id_nodes, grep($_->hasAttribute('id'), @child));
        push(@id_nodes, nodes_with_id($_))     # recursive
          for @child;
    }
    else {
        return;
    }

    return(@id_nodes);
}

sub header_file_id {
    my ($root) = @_;
    my @File_nodes = $root->getChildrenByTagName('File');

    my ($header_file_node) = grep { $_->getAttribute('name') =~ m{\bgenscripts/} } @File_nodes;
    unless ($header_file_node) {
        die "Didn't find header File node";
    }

    my $id = $header_file_node->getAttribute('id');
    return($id);
}

sub top_nodes_from_header_file {
    my ($root) = @_;

    my $header_file_id = header_file_id($root);
    my @child_element_nodes = child_element_nodes($root);
    my @nodes = grep { ($_->getAttribute('file') // '') eq $header_file_id } @child_element_nodes;
    return(@nodes);
}

sub child_element_nodes {
    my ($node) = @_;
    my @nodes = grep {
        $_->nodeType == XML_ELEMENT_NODE   # excludes Text nodes
    } $node->childNodes;
    return(@nodes);
}

sub process_top_nodes {
    my ($nodes, $nodes_by_id) = @_;

    # Pass through all the top-level nodes to gather data,
    # since they can refer to other top-level nodes, even those later in the file.
    # { Function => { "_308" => { name => "rd_kafka_version", ... }, ... }, ... }
    my $nodes_by_name = node_data($nodes);

    link_data_together($nodes_by_name, $nodes_by_id);

}

sub link_data_together {
    my ($nodes_by_name, $nodes_by_id) = @_;

    link_structs($nodes_by_name, $nodes_by_id);   # deletes Field
    print Dumper($nodes_by_name->{Struct});exit;
}

sub link_structs {
    my ($nodes_by_name, $nodes_by_id) = @_;

    # Field are elements of Struct
    my $fields = delete($nodes_by_name->{Field});    # bye!
    my $structs = $nodes_by_name->{Struct};
    my $typedefs = $nodes_by_name->{Typedef};
    my %cached_typedef_by_type;
    foreach my $struct_id (keys %$structs) {
        my $struct = $structs->{$struct_id};
        if ($struct->{incomplete}) {
            my $typedef = $cached_typedef_by_type{$struct_id};
            unless ($typedef) {
                foreach my $typedef_id (keys %$typedefs) {
                    my $t = $typedefs->{$typedef_id};
                    if ($t->{type} eq $struct_id) {
                        $typedef = $cached_typedef_by_type{$struct_id} = $t;
                    }
                }
            }
            $struct->{typedef} = {
                id => $typedef->{id},
                name => $typedef->{name},
            };
        }

        my @member_ids = split(' ', $struct->{members});
        foreach my $member_id (@member_ids) {
            my $field = $fields->{$member_id}
              or die("Struct '$struct_id' member '$member_id' not found");

            push @{ $struct->{fields} }, {
                name => $field->{name},

                # _type lookup

            };
        }
    }
}

sub node_data {
    my ($nodes) = @_;
    my %nodes_by_name;

    foreach my $node (@$nodes) {
        my $node_name = $node->nodeName;
        my $cb = 'cb_' . $node_name;
        if (defined(&$cb)) {
            my ($id, $data) = do {
                no strict 'refs';
                $cb->($node);
            };
            next unless $id;

            $nodes_by_name{$node_name}{$id} = $data;
        }
        else {
            print "UNHANDLED callback '$node_name'\n";
        }
    }

    return(\%nodes_by_name);
}

sub cb_Enumeration {
    my ($node) = @_;
    my $id = $node->getAttribute('id');

    my %attr = map +($_ => $node->getAttribute($_)), qw/name type/;

    my @enum_value = map($_->getAttribute('name'), child_element_nodes($node));   # <EnumValue>
    $attr{enum_values} = \@enum_value;

    return($id => \%attr);
}

# might need to be by id instead of name (maybe should redo them all by id)
sub cb_Field {
    my ($node) = @_;
    my $id = $node->getAttribute('id');

    my %attr = map +($_ => $node->getAttribute($_)), qw/name type/;

    return($id => \%attr);
}

sub cb_Function {
    my ($node) = @_;
    my $id = $node->getAttribute('id');

    my %attr = map +($_ => $node->getAttribute($_)), qw/name returns type/;

    my @arg;
    foreach my $arg_node (child_element_nodes($node)) {    # <Argument>
        push @arg, { map( +($_ => $arg_node->getAttribute($_) ), qw/name type/) };
    }
    $attr{arguments} = \@arg;

    return($id => \%attr);
}

sub cb_Struct {
    my ($node) = @_;
    my $id = $node->getAttribute('id');

    # Struct elements will probably be generally gnarly.
    # Some structs are defined in other header files,
    # when <Struct ... incomplete="1"> and name ends with "_s".
    # Those also have a corresponding <Typedef> whose name ends with "_t".
    # I guess I'll just do those manually.

    my %attr = map +($_ => $node->getAttribute($_)), qw/incomplete members name/;

    return($id => \%attr);
}

sub cb_Typedef {
    my ($node) = @_;
    my $id = $node->getAttribute('id');

    my %attr = map +($_ => $node->getAttribute($_)), qw/id name type/;

    return($id => \%attr);
}
