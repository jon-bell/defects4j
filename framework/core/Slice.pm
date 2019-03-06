#-------------------------------------------------------------------------------
# Copyright (c) 2014-2018 René Just, Darioush Jalali, and Defects4J contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

=pod

=head1 NAME

Slice.pm -- helper subroutines for dynamic slicing analysis.

=head1 DESCRIPTION

This module provides helper subroutines for dynamic slicing analysis using the
Java slicer tool developed by Clemens Hammacher at Saarland University.

=cut
package Slice;

use warnings;
use strict;

use Constants;
use Utils;

=pod

=head2 Static subroutines

  Slice::tracing(project, single_test, trigger_test_log_file, trace_output_file, log_file)

Run tracing for a provided project version.

C<single_test> is the name of the test method to run, format of C<single_test>
is <classname>::<methodname>. F<trigger_test_log_file> is the name of the file
to where the stack trace of each test method is writen. F<trace_output_file> is
the name of the file to where dynamic backward tracing of each test method is
written.

=cut
sub tracing {
    @_ == 5 or die $ARG_ERROR;
    my ($project, $single_test, $trigger_test_log_file, $trace_output_file, $log_file) = @_;

    $project->dynamic_tracing($single_test, $trigger_test_log_file, $trace_output_file, $log_file)
        or die "Dynamic-tracing has failed for test case $single_test";
    if (! -e $trace_output_file) {
        system("cat $log_file");
        die "Trace output file ($trace_output_file) does not exist!";
    }

    return;
}

=pod

  Slice::slicing(project, loaded_classes_file, trigger_test_log_file, trace_output_file, slice_output_file, log_file)

Run slicing for a provided project version.

F<loaded_classes_file> is the name of the file with all loaded classes.
F<trigger_test_log_file> is the name of the file that contains the stack trace
of the trigger test method. F<slice_output_file> is the name of the file to
where slice of a previously computed trace F<trace_output_file> is written.

=cut
sub slicing {
    @_ == 6 or die $ARG_ERROR;
    my ($project, $loaded_classes_file, $trigger_test_log_file, $trace_output_file, $slice_output_file, $log_file) = @_;

    open my $fh, $trigger_test_log_file or die "Could not log of trigger test $trigger_test_log_file";
    my $criteria = undef;
    while (<$fh>) {
        chomp;
        if (/\s+at ([^(]+)\([^:]+:(\d+)\)/) {
            $criteria = $1 . ":" . $2; # class_method_name : line_number
            last;
        }
    }
    close($fh);
    defined $criteria or die "Stack trace of trigger test case is empty or not well formatted";

    my $slice_output_tmp_file = "$slice_output_file.tmp";
    system(">$slice_output_tmp_file");

    # escape contructor method name
    $criteria =~ s/.<init>:/.\\<init\\>:/;

    $project->dynamic_slicing($criteria, $trace_output_file, $slice_output_tmp_file, $log_file)
        or die "Dynamic-slicing has failed";
    if (! -e $slice_output_tmp_file) {
        system("cat $log_file");
        die "Slice output file ($slice_output_tmp_file) does not exist!";
    }

    # filter out lines that are not in the project
    system("grep -Ff $loaded_classes_file $slice_output_tmp_file > $slice_output_file");

    return;
}

1;
