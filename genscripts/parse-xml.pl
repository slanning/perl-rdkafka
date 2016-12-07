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
    my @nodes = top_nodes_from_header_file($root);
    process_top_nodes(\@nodes);
}

sub root_node {
    my $doc = XML::LibXML->load_xml(IO => *STDIN);
    my $root = $doc->documentElement();
    return($root);
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
    my ($nodes) = @_;

    # Pass through all the top-level nodes to gather data,
    # since they can refer to other top-level nodes, even those later in the file.
    # { Function => { "_308" => { name => "rd_kafka_version", ... }, ... }, ... }
    my $nodes_by_name = get_node_data($nodes);
    #print Dumper($nodes_by_name);

    # Now tie the data together.


}

sub get_node_data {
    my ($nodes) = @_;

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

    my %attr = map +($_ => $node->getAttribute($_)), qw/name type/;

    return($id => \%attr);
}
