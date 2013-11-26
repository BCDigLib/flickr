#!/usr/bin/perl -w
   
use strict;
use FileHandle;
use Switch;
use File::Copy;

use Image::ExifTool;

my @description;
my %newDescription;

main();

#-----------------------------------------------------------------------------
sub main {
    
    my $file = shift @ARGV
        if (@ARGV);							
    testStuff();
    readDescriptions($file);
    
    
# Read filename keys to process
    while ( my ($filename, $coordinates) = each(%newDescription) ) {
    
    print "$filename\n";
	#Create backup image
	#my $backup = "orig_" . $filename;
	#copy($filename,$backup)
	#    or die "Backup failed: $!";
	    
	    my $exifTool = new Image::ExifTool;
	    
# Pull Image Description to see if it exists
	my $info = Image::ExifTool::ImageInfo($filename, @description);
	my $count = scalar keys %$info;
	
	if ($count => 20) {
	print "There is nothing here\n";
	
	#my $newkeywords;
	#   $newkeywords = 
	#   $newDescription{$filename} -> {'imgkeywords'};
	#my @descriptionarray = split(/;/, $newkeywords);
	#	foreach(@descriptionarray) {
	#	print "We added new keywords and they are @descriptionarray\n";
	#	my ($success, $error) = $exifTool->SetNewValue('Keywords', $_);
	#    }
	#    $exifTool->ExtractInfo($filename);

    my %newtitle;
        $newtitle{'Title'} =
        $newDescription{$filename} -> {'imgtitle'};
        for my $exifTag ( keys %newtitle ) {
		print "$exifTag is $newtitle{$exifTag}\n";
		my ($success, $error) = $exifTool->ExtractInfo($exifTag, $newtitle{$exifTag});
	    }
	    $exifTool->WriteInfo($file);
	    
	#my %newimgdescription;
    #    $newimgdescription{'Description'} =
    #    $newDescription{$filename} -> {'imgdesc'};
    #    for my $exifTag ( keys %newimgdescription ) {
	#	print "$exifTag is $newimgdescription{$exifTag}\n";
	#	my ($success, $error) = $exifTool->SetNewValue($exifTag, $newimgdescription{$exifTag});
	#    }
	#    $exifTool->ExtractInfo($filename);
	}

	    
	  
#-----------------------------------------------------------------------------
sub testStuff {
    
    @description = ("Keywords", "Title", "Description");
    }
    
    
#-----------------------------------------------------------------------------
sub readDescriptions {    
    
    my $file = shift;
    $file =~ tr/\;/,/;
   
    
    my $fh = new FileHandle();
    $fh->open($file);
    
    while( not($fh->eof()) )
    {
	my $line = $fh->getline();
	my ($filename, $imgkeywords, $imgtitle, $imgdesc) = split(/\t/, $line);
    
    $newDescription{ $filename } =
	{
            imgkeywords   => $imgkeywords,
            imgtitle => $imgtitle,
            imgdesc => $imgdesc,

	};
    }
    
    
    
    }