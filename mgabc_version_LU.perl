#!/usr/bin/perl


##TODO: integrate this with grocess, replace s/<sc>// with regular expression with <sc\b[^>]*>(.*?)</sc>
##	ensure newline between each entry in main file
##	then start typesetting Psalms :)

use strict;
use IO::File;

my $GABCFILE = $ARGV[0];
my $GABCOUT = $GABCFILE;
my $GABCNAME = $GABCFILE;
$GABCNAME =~ s/.gabc$//;
my $GABCSCORES = $GABCFILE;
$GABCSCORES =~ s/.gabc/scores.txt/;
my $TEXT;
my $FLFILE;
my $FLTEX;
my $FL1;
my $FL2;
my $CODE;
my $INIT;
my $INIT1;
my $INIT2;
my $INIT3;
my $KEEPSEARCHING = 1;
my $KEEPSEARCHINGFL = 1;
my $INLINE = "";
my $SCCOUNT = 0;
my $TXCOUNT = 0;

my $SCORENAME;

my $ANNOTATION;
my $MODE;
my $REFERENCE;
my $OFFICEPART;
my $NAMEFOUND = 0;


my $GABCFILES = $GABCFILE;
$GABCFILES =~ s/.gabc/-full.tex/;

my $OUTDIR = "/iomega/CP/gabc/LU";
my $OUTDIRDAY = "/iomega/CP/day/LU";
my $OUTDIRTEX = "/iomega/CP/tex/LU";
my $OUTDIRPDF = "/iomega/CP/pdf/LU";

#Fancy first initial character
my $FF = 1;

##


##


## Remove previous temp file
system ("rm ./temp.tex");

## Create new temp file
my $TEMPFILE = "./temp.tex";

## insert headers to temp
open (OUTPUTTEMP,">>".$TEMPFILE);

## Read in the template
my @TEMPLATELINES;

@TEMPLATELINES = <DATA>;

## Name of the Score
open (GABC,"<".$GABCFILE) or die "No such file: $GABCFILE\n";
$INLINE = <GABC>;
if ($INLINE =~ /^name/) {
    $SCORENAME = $INLINE;
    $SCORENAME =~ s/^.*:\s*//;
    $SCORENAME =~ s/\s*;\s*$//;
}



&do_subst ("XXXX-GABCFILES-XXXX", $GABCFILES);
&do_subst ("XXXX-SCORENAME-XXXX", $SCORENAME);

## Create main wrapper
my $WRAPPER = $GABCFILE;
$WRAPPER =~ s/.gabc$/-main.tex/;

my $PDFOUTPUT = $WRAPPER;
$PDFOUTPUT =~ s/tex$/pdf/;
my $PDFSHORT = $PDFOUTPUT;
$PDFSHORT =~ s/-main.pdf/pdf/;

open (TEXWRAP,">".$WRAPPER) or die "Cannot write file $WRAPPER\n";
print TEXWRAP @TEMPLATELINES;
close (TEXWRAP);


## Split original gabc, add references in temp
open (GABC,"<".$GABCFILE) or die "No such file: $GABCFILE\n";
open (SCORES,">>".$GABCSCORES);
while ($KEEPSEARCHING == 1 && ($INLINE = <GABC>)) {
# if inline = tx or sc
  if ($INLINE =~ m/<sc>(.*?)<\/sc>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<sc>//;
  $TEXT =~ s/<\/sc>//;
  $SCCOUNT = $SCCOUNT + 1;
  $GABCOUT =~ s/.gabc$/$SCCOUNT.gabc/;
  print "$GABCOUT\n";
  print "$INLINE";
#  print "$SCCOUNT\n";
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (OUTPUT,">".$GABCOUT);
  print OUTPUT "name:;\n";
  print OUTPUT "centering-scheme:english;\n";
  print OUTPUT "%%\n";
  print OUTPUT "$TEXT";
  print SCORES "$SCCOUNT: $TEXT";
  system ("gregorio $GABCOUT");
  system ("/home/ahinkley/gprocess_eps_quiet $GABCNAME$SCCOUNT 4.5");
  $GABCOUT =~ s/.gabc$/.tex/;
  print OUTPUTTEMP "\\includescore\{$GABCOUT\}\n";
  $INLINE =~ s/<sc>(.*?)<\/sc>//;
  close (OUTPUT);
  close (OUTPUTTEMP);

  $GABCOUT = $GABCFILE;

  }

#g3 gabc with {init1}{init2}{commentary}
  if ($INLINE =~ m/<g3>(.*?)<\/g3>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<g3>//;
  $TEXT =~ s/<\/g3>.*//;
  $INIT = $INLINE;
  $INIT =~ s/.*<\/g3>//;
  $INIT =~ s/[^}]*$//;
  $INIT1 = $INIT;
  $INIT1 =~ s/^{//;
  $INIT1 =~ s/}.*//;
  $INIT2 = $INIT;
  $INIT2 =~ s/^[^}]*}{//;
  $INIT2 =~ s/}{[^}]*}$//;
  $INIT3 = $INIT;
  $INIT3 =~ s/.*}{//;
  $INIT3 =~ s/}$//;
  $SCCOUNT = $SCCOUNT + 1;
  $GABCOUT =~ s/.gabc$/$SCCOUNT.gabc/;
  print "$GABCOUT\n";
  print "$INLINE";
#  print "$SCCOUNT\n";
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (OUTPUT,">".$GABCOUT);
  print OUTPUT "name:;\n";
  print OUTPUT "annotation:$INIT1;\n";
  print OUTPUT "mode:$INIT2;\n";
  print OUTPUT "commentary:$INIT3;\n";
  print OUTPUT "%%\n";
  print OUTPUT "$TEXT";
  print SCORES "$SCCOUNT: $TEXT";
  system ("gregorio $GABCOUT");
  system ("/home/ahinkley/gprocess_eps_quiet $GABCNAME$SCCOUNT 4.5");
  $GABCOUT =~ s/.gabc$/.tex/;
  print OUTPUTTEMP "\\ginit$INIT\n";
#  print OUTPUTTEMP "\\ginit1\{$INIT1\}\n";
#  print OUTPUTTEMP "\\ginit2\{$INIT2\}\n";
#  print OUTPUTTEMP "\\scrf\{$INIT3\}\n";
  print OUTPUTTEMP "\\includescore\{$GABCOUT\}\n";
  $INLINE =~ s/<g3>(.*?)<\/g3>//;
  close (OUTPUT);
  close (OUTPUTTEMP);

  $GABCOUT = $GABCFILE;

  }
#g3e gabc with {init1}{init2}{commentary} and English spacing
  if ($INLINE =~ m/<g3e>(.*?)<\/g3e>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<g3e>//;
  $TEXT =~ s/<\/g3e>.*//;
  $INIT = $INLINE;
  $INIT =~ s/.*<\/g3e>//;
  $INIT =~ s/[^}]*$//;
  $INIT1 = $INIT;
  $INIT1 =~ s/^{//;
  $INIT1 =~ s/}.*//;
  $INIT2 = $INIT;
  $INIT2 =~ s/^[^}]*}{//;
  $INIT2 =~ s/}{[^}]*}$//;
  $INIT3 = $INIT;
  $INIT3 =~ s/.*}{//;
  $INIT3 =~ s/}$//;
  $SCCOUNT = $SCCOUNT + 1;
  $GABCOUT =~ s/.gabc$/$SCCOUNT.gabc/;
  print "$GABCOUT\n";
  print "$INLINE";
#  print "$SCCOUNT\n";
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (OUTPUT,">".$GABCOUT);
  print OUTPUT "name:;\n";
  print OUTPUT "centering-scheme english;\n";
  print OUTPUT "%%\n";
  print OUTPUT "$TEXT";
  print SCORES "$SCCOUNT: $TEXT";
  system ("gregorio $GABCOUT");
  system ("/home/ahinkley/gprocess_eps_quiet $GABCNAME$SCCOUNT 4.5");
  $GABCOUT =~ s/.gabc$/.tex/;
  print OUTPUTTEMP "\\gresetfirstlineaboveinitial{\\small \\textsc{\\textbf{$INIT1}}}{\\small \\textsc{\\textbf{$INIT1}}}\n";
  print OUTPUTTEMP "\\setsecondannotation{\\small \\textsc{\\textbf{$INIT2}}}\n";
  print OUTPUTTEMP "\\commentary\{$INIT3\}\n";
  print OUTPUTTEMP "\\includescore\{$GABCOUT\}\n";
  $INLINE =~ s/<sc>(.*?)<\/sc>//;
  close (OUTPUT);
  close (OUTPUTTEMP);

  $GABCOUT = $GABCFILE;

  }


##sl - Score with Latin spacing
open (GABC,"<".$GABCFILE) or die "No such file: $GABCFILE\n";
open (SCORES,">>".$GABCSCORES);
while ($KEEPSEARCHING == 1 && ($INLINE = <GABC>)) {
# if inline = tx or sc
  if ($INLINE =~ m/<sc>(.*?)<\/sc>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<sc>//;
  $TEXT =~ s/<\/sc>//;
  $SCCOUNT = $SCCOUNT + 1;
  $GABCOUT =~ s/.gabc$/$SCCOUNT.gabc/;
  print "$GABCOUT\n";
  print "$INLINE";
#  print "$SCCOUNT\n";
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (OUTPUT,">".$GABCOUT);
  print OUTPUT "name:;\n";
  print OUTPUT "%%\n";
  print OUTPUT "$TEXT";
  print SCORES "$SCCOUNT: $TEXT";
  system ("gregorio $GABCOUT");
  system ("/home/ahinkley/gprocess_eps_quiet $GABCNAME$SCCOUNT 4.5");
  $GABCOUT =~ s/.gabc$/.tex/;
  print OUTPUTTEMP "\\includescore\{$GABCOUT\}\n";
  $INLINE =~ s/<sc>(.*?)<\/sc>//;
  close (OUTPUT);
  close (OUTPUTTEMP);

  $GABCOUT = $GABCFILE;

  }


#ft tag:	Include tex file
if ($INLINE =~ m/<ft>(.*?)<\/ft>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<ft>//;
  $TEXT =~ s/<\/ft>//;
# Not quite sure why I had to add this. Maybe a fault with gpr2?
  $TEXT =~ s/\n//;
#If there is an output directory:
#  system("cp $GABCOUT $OUTDIR");
#  system("echo XXXX $CODE\_-\_");
#  system("echo XXXX $TEXT $CODE\_-\_$TEXT");
#  system("echo XXXX $OUTDIR/$CODE\_-\_");
#  system("echo XXXX $CODE\_-\_$TEXT $OUTDIR");
#  system("echo XXXX $OUTDIR/$CODE\_-\_$TEXT");
#  system("echo XXXX cp $TEXT $OUTDIR/$CODE\_-\_$TEXT");
#  system("cp $TEXT $CODE\_-\_$TEXT");
#  system("ls -l $TEXT $CODE\_-\_$TEXT");
#  system("echo ");
#  system("cp $TEXT $OUTDIR/$CODE\_-\_$TEXT");
  system("cp $TEXT $OUTDIR");
  $TEXT =~ s/.tex$//;
  open (OUTPUTTEMP,">>".$TEMPFILE);
  print OUTPUTTEMP "\\input{$TEXT}\\par\n";
  $INLINE =~ s/<ft>(.*?)<\/ft>//;
  close (OUTPUTTEMP);
  }

#fi tag:	Introits, Kyrie
#		Use fancy initial

if ($INLINE =~ m/<fi>(.*?)<\/fi>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<fi>//;
  $TEXT =~ s/<\/fi>//;
  $TEXT =~ s/\n//;
  $KEEPSEARCHINGFL = 1;
  $FLFILE = $TEXT;
  $FLTEX = $FLFILE;
  $FLTEX =~ s/.gabc$/.tex/;
  system("gregorio $TEXT");
  
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (GABCFL,"<".$TEXT) or die "No such file: $TEXT\n";
  while ($KEEPSEARCHINGFL == 1 && ($INLINE = <GABCFL>)) {
    if ($INLINE =~ /^annotation/) {
      $ANNOTATION = $INLINE;
      $ANNOTATION =~ s/^.*:\s*//;
      $ANNOTATION =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^mode/) {
      $MODE = $INLINE;
      $MODE =~ s/^.*:\s*//;
      $MODE =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^commentary/) {
      $REFERENCE = $INLINE;
      $REFERENCE =~ s/^.*:\s*//;
      $REFERENCE =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^office-part/) {
      $OFFICEPART = $INLINE;
      $OFFICEPART =~ s/^.*:\s*//;
      $OFFICEPART =~ s/\s*;\s*$//;
    };
  if ($INLINE =~ /^%%/) { $KEEPSEARCHINGFL = 0; }

  }
  close (GABCFL);

  print OUTPUTTEMP "\\renewcommand*\\initfamily{\\usefont{U}{Acorn}{xl}{n}}\n";
  print OUTPUTTEMP "\\gresetfirstlineaboveinitial{\\small \\textsc{\\textbf{$ANNOTATION}}}{\\small \\textsc{\\textbf{$ANNOTATION}}}\n";
  print OUTPUTTEMP "\\setsecondannotation{\\small \\textsc{\\textbf{$MODE}}}\n";
  print OUTPUTTEMP "\\nopagebreak\n";
  print OUTPUTTEMP "\\commentary{{\\small \\red{\\emph{$REFERENCE}}}}\\nopagebreak\n";
  print OUTPUTTEMP "\\includescore{$FLTEX}\n";
  if ($FF == 1) {
    print OUTPUTTEMP "\\renewcommand*\\initfamily{\\tgothfamily}\n\n";
    $FF = 0;
  }

  close (OUTPUTTEMP);
  print "The scorename is $SCORENAME\n";
  print "The scorename is $TEXT\n";
#  print "The code is $CODE\n";
#  print ("cp $TEXT $CODE\_-\_$TEXT");
#If there is an output directory:
#  system("cp $TEXT $OUTDIR/$CODE\_-\_$TEXT");
  system("cp $TEXT $OUTDIR");
#  system("echo ");
#  system("echo $TEXT $OUTDIR/$CODE\_-\_$TEXT\n\n");
#  system("echo ");
  $MODE = "";
}








#fj tag:	Use Gothic initial

if ($INLINE =~ m/<fj>(.*?)<\/fj>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<fj>//;
  $TEXT =~ s/<\/fj>//;
  $TEXT =~ s/\n//;
  $KEEPSEARCHINGFL = 1;
  $FLFILE = $TEXT;
  $FLTEX = $FLFILE;
  $FLTEX =~ s/.gabc$/.tex/;
  system("gregorio $TEXT");
  
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (GABCFL,"<".$TEXT) or die "No such file: $TEXT\n";
  while ($KEEPSEARCHINGFL == 1 && ($INLINE = <GABCFL>)) {
    if ($INLINE =~ /^annotation/) {
      $ANNOTATION = $INLINE;
      $ANNOTATION =~ s/^.*:\s*//;
      $ANNOTATION =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^mode/) {
      $MODE = $INLINE;
      $MODE =~ s/^.*:\s*//;
      $MODE =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^commentary/) {
      $REFERENCE = $INLINE;
      $REFERENCE =~ s/^.*:\s*//;
      $REFERENCE =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^office-part/) {
      $OFFICEPART = $INLINE;
      $OFFICEPART =~ s/^.*:\s*//;
      $OFFICEPART =~ s/\s*;\s*$//;
    };
  if ($INLINE =~ /^%%/) { $KEEPSEARCHINGFL = 0; }

  }
  close (GABCFL);

  print OUTPUTTEMP "\\renewcommand*\\initfamily{\\tgothfamily}\n\n";
  print OUTPUTTEMP "\\gresetfirstlineaboveinitial{\\small \\textsc{\\textbf{$ANNOTATION}}}{\\small \\textsc{\\textbf{$ANNOTATION}}}\n";
  print OUTPUTTEMP "\\setsecondannotation{\\small \\textsc{\\textbf{$MODE}}}\n";
  print OUTPUTTEMP "\\nopagebreak\n";
  print OUTPUTTEMP "\\commentary{{\\small \\red{\\emph{$REFERENCE}}}}\\nopagebreak\n";
  print OUTPUTTEMP "\\includescore{$FLTEX}\n";
#  if ($FF == 1) {
#    print OUTPUTTEMP "\\renewcommand*\\initfamily{\\tgothfamily}\n\n";
#    $FF = 0;

  close (OUTPUTTEMP);
  print "The scorename is $SCORENAME\n";
#  print "The code is $CODE\n";
#  print ("cp $TEXT $CODE\_-\_$TEXT");
#If there is an output directory:
#  system("cp $TEXT $OUTDIR/$CODE\_-\_$TEXT");
  system("cp $TEXT $OUTDIR");
#  system("echo ");
#  system("echo $TEXT $OUTDIR/$CODE\_-\_$TEXT\n\n");
#  system("echo ");
  $MODE = "";
}







#ff tag:	Include file

if ($INLINE =~ m/<ff>(.*?)<\/ff>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<ff>//;
  $TEXT =~ s/<\/ff>//;
  $TEXT =~ s/\n//;
  $KEEPSEARCHINGFL = 1;
  $FLFILE = $TEXT;
  $FLTEX = $FLFILE;
  $FLTEX =~ s/.gabc$/.tex/;
  system("gregorio $TEXT");
  print("$TEXT");
  
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (GABCFL,"<".$TEXT) or die "No such file: $TEXT\n";
  while ($KEEPSEARCHINGFL == 1 && ($INLINE = <GABCFL>)) {
    if ($INLINE =~ /^annotation/) {
      $ANNOTATION = $INLINE;
      $ANNOTATION =~ s/^.*:\s*//;
      $ANNOTATION =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^mode/) {
      $MODE = $INLINE;
      $MODE =~ s/^.*:\s*//;
      $MODE =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^commentary/) {
      $REFERENCE = $INLINE;
      $REFERENCE =~ s/^.*:\s*//;
      $REFERENCE =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^office-part/) {
      $OFFICEPART = $INLINE;
      $OFFICEPART =~ s/^.*:\s*//;
      $OFFICEPART =~ s/\s*;\s*$//;
    };
  if ($INLINE =~ /^%%/) { $KEEPSEARCHINGFL = 0; }

  }
  close (GABCFL);

  print OUTPUTTEMP "\\gresetfirstlineaboveinitial{\\small \\textsc{\\textbf{$ANNOTATION}}}{\\small \\textsc{\\textbf{$ANNOTATION}}}\n";
  print OUTPUTTEMP "\\setsecondannotation{\\small \\textsc{\\textbf{$MODE}}}\n";
  print OUTPUTTEMP "\\nopagebreak\n";
  print OUTPUTTEMP "\\commentary{{\\small \\red{\\emph{$REFERENCE}}}}\\nopagebreak\n";
  print OUTPUTTEMP "\\includescore{$FLTEX}\n";
  if ($FF == 1) {
    print OUTPUTTEMP "\\renewcommand*\\initfamily{\\tgothfamily}\n\n";
    $FF = 0;
  }

  close (OUTPUTTEMP);
  print "The scorename is $SCORENAME\n";
  print "The scorename is $TEXT\n";
#  print "The code is $CODE\n";
#  print ("cp $TEXT $CODE\_-\_$TEXT");
#If there is an output directory:
#  system("cp $TEXT $OUTDIR/$CODE\_-\_$TEXT");
  system("cp $TEXT $OUTDIR");
#  system("echo ");
#  system("echo $TEXT $OUTDIR/$CODE\_-\_$TEXT\n\n");
#  system("echo ");
  $MODE = "";
}

#fa tag:	Antiphon with additional annotation above Initial
if ($INLINE =~ m/<fa>(.*?)<\/fa>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<fa>//;
  $TEXT =~ s/<\/fa>.*//;
  $TEXT =~ s/\n//;
  $KEEPSEARCHINGFL = 1;
  $FLFILE = $TEXT;
  $FLTEX = $FLFILE;
  $FL1 = $INLINE;
  $FL1 =~ s/<fa>.*<\/fa>//;
  $FLTEX =~ s/.gabc$/.tex/;
  system("gregorio $TEXT");
  
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (GABCFL,"<".$TEXT) or die "No such file: $TEXT\n";
  while ($KEEPSEARCHINGFL == 1 && ($INLINE = <GABCFL>)) {
    if ($INLINE =~ /^annotation/) {
      $ANNOTATION = $INLINE;
      $ANNOTATION =~ s/^.*:\s*//;
      $ANNOTATION =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^mode/) {
      $MODE = $INLINE;
      $MODE =~ s/^.*:\s*//;
      $MODE =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^commentary/) {
      $REFERENCE = $INLINE;
      $REFERENCE =~ s/^.*:\s*//;
      $REFERENCE =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^office-part/) {
      $OFFICEPART = $INLINE;
      $OFFICEPART =~ s/^.*:\s*//;
      $OFFICEPART =~ s/\s*;\s*$//;
    };
  if ($INLINE =~ /^%%/) { $KEEPSEARCHINGFL = 0; }

  }
  close (GABCFL);

  print OUTPUTTEMP "\\gresetfirstlineaboveinitial{\\small \\textsc{\\textbf{$FL1 $ANNOTATION}}}{\\small \\textsc{\\textbf{$ANNOTATION}}}\n";
  print OUTPUTTEMP "\\setsecondannotation{\\small \\textsc{\\textbf{$MODE}}}\n";
  print OUTPUTTEMP "\\commentary{{\\small \\red{\\emph{$REFERENCE}}}}\\nopagebreak\n";
  print OUTPUTTEMP "\\includescore{$FLTEX}\n";
  if ($FF == 1) {
    print OUTPUTTEMP "\\renewcommand*\\initfamily{\\tgothfamily}\n\n";
    $FF = 0;
  }

  close (OUTPUTTEMP);
  print "The scorename is $SCORENAME\n";
#  print "The code is $CODE\n";
#  print ("cp $TEXT $CODE\_-\_$TEXT");
#If there is an output directory:
#  system("cp $TEXT $OUTDIR/$CODE\_-\_$TEXT");
  system("cp $TEXT $OUTDIR");
  $MODE = "";
}

####
# fb tag: Override both lines of annotation.
####
if ($INLINE =~ m/<fb>(.*?)<\/fb>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<fb>//;
  $TEXT =~ s/<\/fb>.*//;
  $TEXT =~ s/\n//;
  $KEEPSEARCHINGFL = 1;
  $FLFILE = $TEXT;
  $FLTEX = $FLFILE;
  $FL1 = $INLINE;
  $FL2 = $INLINE;
  $FL1 =~ s/<fb>.*<\/fb>//;
  $FL1 =~ s/\%.*//;
  $FL2 =~ s/.*\%//;


  $FLTEX =~ s/.gabc$/.tex/;
  system("gregorio $TEXT");
  
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (GABCFL,"<".$TEXT) or die "No such file: $TEXT\n";
  while ($KEEPSEARCHINGFL == 1 && ($INLINE = <GABCFL>)) {
    if ($INLINE =~ /^annotation/) {
      $ANNOTATION = $INLINE;
      $ANNOTATION =~ s/^.*:\s*//;
      $ANNOTATION =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^mode/) {
      $MODE = $INLINE;
      $MODE =~ s/^.*:\s*//;
      $MODE =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^commentary/) {
      $REFERENCE = $INLINE;
      $REFERENCE =~ s/^.*:\s*//;
      $REFERENCE =~ s/\s*;\s*$//;
    };
    if ($INLINE =~ /^office-part/) {
      $OFFICEPART = $INLINE;
      $OFFICEPART =~ s/^.*:\s*//;
      $OFFICEPART =~ s/\s*;\s*$//;
    };
  if ($INLINE =~ /^%%/) { $KEEPSEARCHINGFL = 0; }

  }
  close (GABCFL);

  print OUTPUTTEMP "\\gresetfirstlineaboveinitial{\\small \\textsc{\\textbf{$FL1 $ANNOTATION}}}{\\small \\textsc{\\textbf{$ANNOTATION}}}\n";
  print OUTPUTTEMP "\\setsecondannotation{\\small \\textsc{\\textbf{$MODE}}}\n";
  print OUTPUTTEMP "\\commentary{{\\small \\red{\\emph{$REFERENCE}}}}\\nopagebreak\n";
  print OUTPUTTEMP "\\includescore{$FLTEX}\n";
  if ($FF == 1) {
    print OUTPUTTEMP "\\renewcommand*\\initfamily{\\tgothfamily}\n\n";
    $FF = 0;
  }

  close (OUTPUTTEMP);
  print "The scorename is $SCORENAME\n";
#  print "The code is $CODE\n";
#  print ("cp $TEXT $CODE\_-\_$TEXT");
#If there is an output directory:
#  system("cp $TEXT $OUTDIR/$CODE\_-\_$TEXT");
  system("cp $TEXT $OUTDIR");
  $MODE = "";
}

###
###

if ($INLINE =~ m/<tx>(.*?)<\/tx>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<tx>//;
  $TEXT =~ s/<\/tx>//;
  open (OUTPUTTEMP,">>".$TEMPFILE);
  print OUTPUTTEMP "$TEXT\n";
  $INLINE =~ s/<tx>(.*?)<\/tx>//;
  close (OUTPUTTEMP);
  }
if ($INLINE =~ m/[^<]/) {
  $TEXT = $INLINE;
  open (OUTPUTTEMP,">>".$TEMPFILE);
  print OUTPUTTEMP "$TEXT\\par\n";
  $INLINE =~ s/(.*?)//;
  close (OUTPUTTEMP);
  }

#  if ($INLINE =~ /^%%/) { $KEEPSEARCHING = 0; }
}
system ("gprocess_lua $GABCFILE");

close (GABC);

open (TEXWRAP,">".$WRAPPER) or die "Cannot write file $WRAPPER\n";
print TEXWRAP @TEMPLATELINES;
close (TEXWRAP);

##Rename temp file

system("mv $TEMPFILE $GABCFILES");
system("lualatex $WRAPPER");
system("mv $PDFOUTPUT $PDFSHORT");
system("xpdf -g 900x250+0+475 -z 150 -cont $PDFSHORT");
system("cp $PDFSHORT $OUTDIRPDF");
system("cp $GABCFILE $OUTDIRDAY");

## Make substitution in template
sub do_subst {
  my $TAG = $_[0];
  my $VAL = $_[1];

  foreach (@TEMPLATELINES) {
     s/$TAG/$VAL/g;
  }
};
}


#  THE LINES AFTER THIS "END" TAG ARE A TEMPLATE FOR THE TEX FILE TO BE GENERATED
__END__

\documentclass[10pt, letterpaper]{article}
\usepackage{fullpage}
\usepackage{palatino}
\usepackage{tgothic}
%\usepackage{tgtermes}
\usepackage{color}
\usepackage[T1]{fontenc}
\usepackage[utf8]{luainputenc}
\usepackage{gregoriotex}
\usepackage{gregoriosyms}
\usepackage{longtable}
\usepackage{fancyhdr}
%\usepackage{parskip}
%\usepackage{changemargin}
\usepackage{titlesec}

\pagestyle{empty}
\usepackage[margin=0.75in, paperwidth=6in, paperheight=9in]{geometry}
%\setlength{\paperwidth}{6.0in} 
%\setlength{\paperheight}{9.0in}
%\setlength{\textwidth}{4.5in}

\titleformat{\section}{\color{red}\normalfont\huge\bfseries\filcenter}{\color{red}\thesection}{1em}{}
\titleformat{\subsection}{\color{red}\normalfont\Large\bfseries\center}{\color{red}\thesubsection}{1em}{}
\titleformat{\subsubsection}{\color{red}\normalfont\large\bfseries\center}{\color{red}\thesubsubsection}{1em}{}


\begin{document}
\newcommand{\red}[1]{\textcolor{red}{#1}}
\newcommand{\black}[1]{\textcolor{black}{#1}}
\newcommand{\cent}[1]{\begin{center}{#1}\end{center}}
\newcommand{\occasion}[1]{\begin{center}\textcolor{red}{\huge #1}\end{center}}
\newcommand{\scrf}[1]{\commentary{{\small \red{\emph{#1}}}}}
\newcommand{\code}[1]{}
\newcommand{\bigline}{\line(1,0){450}}
\newcommand{\ginit}[3]{\gresetfirstlineaboveinitial{\small \red{\textsc{\textbf{#1}}}}{\small \red{\textsc{\textbf{#1}}}} \setsecondannotation{\small \red{\textsc{\textbf{#2}}}}{\commentary{{\small \red{\emph{#3}}}}}}
%\newcommand{\ginit1}[1]{\gresetfirstlineaboveinitial{\small \textsc{\textbf{#1}}}{\small \textsc{\textbf{#1}}}}
%\newcommand{\ginit2}[1]{\setsecondannotation{\small \textsc{\textbf{#2}}}}


\input Acorn.fd
\newcommand*\initfamily{\usefont{U}{Acorn}{xl}{n}}

\def\greinitialformat#1{%
{\initfamily\fontsize{23}{23}\selectfont\textcolor{red} #1}%
}

\setspacebeforeinitial{3.2mm plus 0em minus 0em}
\setspaceafterinitial{3.2mm plus 0em minus 0em}

\fancyhead[L]{\textbf{\emph{XXXX-OCCASION-XXXX}}}
%\emph{}\\


\setgrefactor{13}
\grespaceabovelines=3mm

\begin{center}\begin{huge}\textsc{XXXX-SCORENAME-XXXX}\end{huge}\end{center}

\includescore{XXXX-GABCFILES-XXXX}

\end{document}


