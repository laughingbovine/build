package Filter;

use warnings;
use strict;

################################################################################

=sub filter_file
Reads a file, pipes it through a filter (anonymous sub), and replaces the file with the filter's result.
Optionally create a backup with the specified backup extension.
=cut
sub filter_file
{
    my ($file_path, $filter, $backup_extension) = @_;

    die "not a file" unless -f $file_path;

    local $/; # slurp mode
    
    my ($fh, $content);

    open($fh, '<', $file_path) or die "could not open $file_path for reading";
    $content = <$fh>;
    close($fh) or die "could not close $file_path";

    if ($backup_extension)
    {
        my $backup_file = $file_path.$backup_extension;

        unless (-f $backup_file)
        {
            open($fh, '>', "$backup_file") or die "could not open $backup_file for writing";
            print $fh $content;
            close($fh) or die "could not close $backup_file";
        }
    }

    $filter->(\$content);

    open($fh, '>', $file_path) or die "could not open $file_path for writing";
    print $fh $content;
    close($fh) or die "could not close $file_path";
}

# same as above but added more options
sub filter_file_better
{
    my ($file, $filter, $options) = @_;

    die "not a file" unless -f $file;

    $options ||= {};

    local $/; # slurp mode
    
    my ($fh, $content);

    # read
    open($fh, '<', $file) or die "could not open $file for reading";
    $content = <$fh>;
    close($fh) or die "could not close $file";

    # backup?
    if ($options->{backup_extension} or $options->{backup_file})
    {
        my $backup_file = $options->{backup_file} ? $options->{backup_file} : $file.$options->{backup_extension};

        if (-f $backup_file)
        {
            die "backup file '$backup_file' already exists";
        }
        else
        {
            open($fh, '>', "$backup_file") or die "could not open $backup_file for writing";
            print $fh $content;
            close($fh) or die "could not close $backup_file";
        }
    }

    # do the filter!
    $filter->(\$content);

    # write
    my $output_file;
    if ($options->{output_extension})
    {
        $output_file = $file.$options->{output_extension};
    }
    elsif ($options->{output_file})
    {
        $output_file = $options->{output_file};
    }
    else
    {
        $output_file = $file; # in-place
    }

    open($fh, '>', $output_file) or die "could not open $output_file for writing";
    print $fh $content;
    close($fh) or die "could not close $output_file";
}

# same as above, but one line at a time
sub filter_file_lines
{
    my ($file, $filter, $options) = @_;

    die "not a file" unless -f $file;

    $options ||= {};

    # backup file?
    my $backup_file = 0;
    if ($options->{backup_extension} or $options->{backup_file})
    {
        $backup_file = $options->{backup_file} ? $options->{backup_file} : $file.$options->{backup_extension};

        if (-f $backup_file)
        {
            die "backup file '$backup_file' already exists";
        }
    }

    # output file
    my $output_file;
    if ($options->{output_extension})
    {
        $output_file = $file.$options->{output_extension};
    }
    elsif ($options->{output_file})
    {
        $output_file = $options->{output_file};
    }
    else
    {
        $output_file = $file; # in-place
    }

    # now do the filter
    my $content;
    my ($ifh, $ofh, $bfh);

    open($ifh, '<', $file) or die "could not open $file for reading";
    open($ofh, '>', $output_file) or die "could not open $output_file for writing";
    if ($backup_file)
    {
        open($bfh, '>', $backup_file) or die "could not open $backup_file for writing";
    }

    while ($content = <$ifh>)
    {
        if ($backup_file)
        {
            print $bfh $content;
        }
        $filter->(\$content);
        print $ofh $content;
    }

    close($ifh) or die "could not close $file";
    close($ofh) or die "could not close $output_file";
    if ($backup_file)
    {
        close($bfh) or die "could not close $backup_file";
    }
}

sub filter_file_eval
{
    my ($file, $vars, $options) = @_;

    die "not a file" unless -f $file;

    $options ||= {};

    # output file
    my $output_file;
    if ($options->{output_extension})
    {
        $output_file = $file.$options->{output_extension};
    }
    elsif ($options->{output_file})
    {
        $output_file = $options->{output_file};
    }
    else
    {
        $output_file = $file; # in-place
    }

    # now do the filter
    my $content;
    my @output;
    my ($ifh, $ofh);

    open($ifh, '<', $file) or die "could not open $file for reading";

    my @print   = (1);
    my @else    = (0);

    while ($content = <$ifh>)
    {
        if ($content =~ /^#(if|elsif|else|endif)\s*(.*)\s*$/i)
        {
            my ($logic, $test) = ($1, $2);

            $logic = lc($logic);

            $test =~ s|\$(\w+)|\$vars->{'$1'}|g if $test;

            if ($logic eq 'if')
            {
                my $retval = eval $test;
                die "eval error: $@" unless defined $retval;

                if ($print[-1]) # continue printing only if we're currently printing
                {
                    if ($retval)
                    {
                        push @print,    1;
                        push @else,     0;
                    }
                    else
                    {
                        push @print,    0;
                        push @else,     1;
                    }
                }
                else # otherwise we dont care
                {
                    push @print,    0;
                    push @else,     0;
                }
            }
            elsif ($logic eq 'elsif')
            {
                my $retval = eval $test;
                die "eval error: $@" unless defined $retval;

                if ($retval && $else[-1])
                {
                    $print[-1]  = 1;
                    $else[-1]   = 0;
                }
                else
                {
                    $print[-1]  = 0;
                }
            }
            elsif ($logic eq 'else')
            {
                if ($else[-1])
                {
                    $print[-1]  = 1;
                    $else[-1]   = 0;
                }
                else
                {
                    $print[-1] = 0;
                }
            }
            elsif ($logic eq 'endif')
            {
                pop @print;
                pop @else;
            }

            next;
        }

        if ($print[-1])
        {
            push @output, $content;
        }
    }

    close($ifh) or die "could not close $file";

    open($ofh, '>', $output_file) or die "could not open $output_file for writing";
    print $ofh $_ foreach @output;
    close($ofh) or die "could not close $output_file";

    die "unbalanced #if's and #endif's" unless @print == 1 and @else == 1;
}

=sub filter_directory
Recursively reads through a directory, and returns a list of directory entries that pass the filter's (anonymous sub) test.
=cut
sub filter_directory
{
    my ($dir, $filter) = @_;

    $dir =~ s|/+$||; # remove trailing slashes

    die "not a directory" unless -d $dir;

    my ($dh, $entry);
    my @results;

    opendir($dh, $dir) or die "could not open directory $dir";

    while ($_ = readdir($dh))
    {
        next if $_ =~ m|^\.+$|;

        $entry = $dir.'/'.$_;

        push @results, $entry if $filter->($entry);

        if (-d $entry) # recursive
        {
            push @results, filter_directory($entry, $filter);
        }
    }

    closedir($dh) or die "could not close directory $dir";

    return @results;
}

# filter helpers
################################################################################

sub generate_subfilter
{
    my ($search, $subfilter) = @_;

    return sub {
        ${$_[0]} =~ s/$search/$subfilter->($&)/ge;
    };
}

sub generate_filter_group
{
    my (@filters) = @_;

    return sub {
        foreach my $filter (@filters)
        {
            $filter->($_[0]);
        }
    };
}

################################################################################

1;
