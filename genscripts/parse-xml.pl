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
    process_nodes(\@nodes);
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

sub process_nodes {
    my ($nodes) = @_;

    my %nodes_by_name;
    foreach my $node (@$nodes) {
        my $node_name = $node->nodeName;
        my $cb = 'cb_' . $node_name;
        if (defined(&$cb)) {
            my ($name, $data) = do {
                no strict 'refs';
                $cb->($node);
            };

            $nodes_by_name{$node_name}{$name} = $data
              if $name;
        }
        else {
            print "UNHANDLED callback '$node_name'\n";
        }
    }

    print Dumper(\%nodes_by_name);
}

sub cb_Enumeration {
    my ($node) = @_;
    my $name = $node->getAttribute('name');

    my @enum_value = map($_->getAttribute('name'), child_element_nodes($node));

    return($name => \@enum_value);
}

# might need to be by id instead of name (maybe should redo them all by id)
sub cb_Field {
    my ($node) = @_;
    my $name = $node->getAttribute('name');

    my %attr = map +($_ => $node->getAttribute($_)), qw/id type/;

    return($name => \%attr);
}

sub cb_Function {
    my ($node) = @_;

    my $name = $node->getAttribute('name');
    my %attr = map +($_ => $node->getAttribute($_)), qw/id type returns/;

    my @arg;
    foreach my $arg_node (child_element_nodes($node)) {
        push @arg, { map( +($_ => $arg_node->getAttribute($_) ), qw/name type/) };
    }
    $attr{arguments} = \@arg;

    return($name => \%attr);
}

sub cb_Struct {
    my ($node) = @_;
    my $name = $node->getAttribute('name');

    # some structs are defined in other header files...
    # and typedefs

    my %attr = map +($_ => $node->getAttribute($_)), qw/id name members/;

    # struct elements will probably be generally gnarly

    return($name => \%attr);
}

sub cb_Typedef {
    my ($node) = @_;
    my $name = $node->getAttribute('name');

    my %attr = map +($_ => $node->getAttribute($_)), qw/id name type/;

    return;
}
