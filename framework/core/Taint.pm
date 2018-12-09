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

Taint.pm -- helper subroutines for taint tracking and taint analysis.

=head1 DESCRIPTION

This module provides helper subroutines for taint tracking and taint analysis
using the Flabug tool.

=cut
package Taint;

use warnings;
use strict;

use Constants;
use Utils;

=pod

=head2 Static subroutines

  Taint::tracking(project, taint_lines_file, single_test, log_file)

Run taint tracking for a provided project version.

F<taint_lines_file> is the name of a file that lists all source code lines which
should be tainted. C<single_test> is the name of the test method to run, format
of C<single_test> is <classname>::<methodname>.

=cut
sub tracking {
    @_ == 4 or die $ARG_ERROR;
    my ($project, $taint_lines_file, $single_test, $log_file) = @_;

    $project->tain_tracking($taint_lines_file, $single_test, $log_file) || die;

    # TODO
    #   - Check whether tain_tracking has produced the expected output files
}

1;
