package QBit::Gettext::PO;

use qbit;

use base qw(QBit::Class);

our $_SEPARATOR = '|__--HS_SEP--__|';

sub add_message {
    my ($self, %opts) = @_;

    throw Exception::BadArguments gettext('Missed required field "%s"', 'message') unless defined($opts{'message'});

    $self->{'__MESSAGES__'} ||= {};

    my $msg =
      $self->{'__MESSAGES__'}{join($_SEPARATOR, $opts{'context'} || '', $opts{'message'}, $opts{'plural'} || '')} ||=
      {};

    if (keys($msg)) {
        push(@{$msg->{'lines'}}, "$opts{'filename'}:$opts{'line'}");
    } else {
        push_hs($msg, hash_transform(\%opts, [qw(context message plural)]));
        $msg->{'lines'} = ["$opts{'filename'}:$opts{'line'}"];
    }
}

sub header {
    return q{# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER
# This file is distributed under the same license as the PACKAGE package.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\n"
"Report-Msgid-Bugs-To: \n"
"POT-Creation-Date: YEAR-MO-DA HO:MI+ZONE\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\n"
"Language-Team: LANGUAGE <LL@li.org>\n"
"Language: \n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=INTEGER; plural=EXPRESSION;\n"

}
}

sub as_string {
    my ($self) = @_;

    my $str = $self->header();

    foreach my $msg (
        sort {
            $a->{'message'} cmp $b->{'message'}
              || ($a->{'context'} || '') cmp($b->{'context'} || '')
              || ($a->{'plural'}  || '') cmp($b->{'plural'}  || '')
        } values(%{$self->{'__MESSAGES__'}})
      )
    {
        $str .= "#: $_\n" foreach @{$msg->{'lines'}};

        $str .= 'msgctxt ' . __quote($msg->{'context'}) . "\n" if defined($msg->{'context'});

        $str .= 'msgid ' . __quote($msg->{'message'}) . "\n";

        if (defined($msg->{'plural'})) {
            $str .= 'msgid_plural ' . __quote($msg->{'plural'}) . "\n";
            $str .= 'msgstr[0] ""' . "\n";
            $str .= 'msgstr[1] ""' . "\n";
        } else {
            $str .= 'msgstr ""' . "\n";
        }

        $str .= "\n";
    }

    return $str;
}

sub write_to_file {
    my ($self, $filename) = @_;

    writefile($filename, $self->as_string());
}

sub __quote {
    my ($str) = @_;

    for ($str) {
        s/\r//g;
        s/"/\\"/g;
    }

    if ($str =~ /\n/) {
        $str =~ s/(.*)\n/"$1\\n"\n/g;
        $str =~ s/\n([^\n]+)\z/\n"$1"/m;
        $str = qq{""\n$str};
    } else {
        $str = qq{"$str"};
    }

    return $str;
}

TRUE;
