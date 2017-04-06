#! /usr/bin/perl -w

#Convert UC file to tab file
use warnings;
use Data::Dumper;
use Text::Table;

my $filename = shift(@ARGV);

open(my $fh,'<', $filename)
    or die "Could not open file '$filename' $!";

my %samples = ();
my %values;
my $nbOTUs = 0; 
while (my $row = <$fh>) {
    chomp $row;
    my @F=split("\t",$row);
    my @sample = split("_",$F[8]);  # e.g Sample01_1
    my $OTU = $F[9];
    $samples{'OTUs'}{$sample[0]}{$OTU}+=1; 
}

my $struct = $samples{OTUs};
my @cols = sort keys %{ $struct };
my @rows = sort keys %{ { map {
    my $x = $_;
    map { $_ => undef }
    keys %{ $struct->{$x} }
                          } @cols } };

my $tb = Text::Table->new('', @cols);

for my $r (@rows) {
    $tb->add($r, map $struct->{$_}{$r} // '0', @cols);
}

print $tb;
