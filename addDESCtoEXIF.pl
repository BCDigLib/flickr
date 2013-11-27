#!/usr/bin/perl -w
   
use strict;
use FileHandle;
use File::Copy;

use Image::ExifTool;

my @oldDescription;
my %imageDescription;

main();

#-----------------------------------------------------------------------------
sub main {
    
    my $file = shift @ARGV
        if (@ARGV);							
    
    setDescription();
    readDescription($file);

    # Read filename keys to process
    while ( my ($filename, $description) = each(%imageDescription) ) {
    
	print "$filename\n";
        #Create backup image
        my $backup = "orig_" . $filename;
        copy($filename,$backup)
            or die "Backup failed: $!";
	   
        # Pull ImageDescription Tags to see if they exist
        my $info = Image::ExifTool::ImageInfo($filename, @oldDescription);
        my $count = scalar keys %$info;
    
        if ($count == 0) {
	    
	    # Create a new object
	    my $exifTool = new Image::ExifTool;
	    
            # Holder for new  values
	    my %newDescription;
	    
	    $newDescription{'ImageDescription'} = $imageDescription{$filename} -> {'ImageDescription'};
					
	    for my $exifTag ( keys %newDescription ) {
	        print "$exifTag is $newDescription{'ImageDescription'}\n";
		
		#Set new value
		$exifTool->SetNewValue($exifTag, $newDescription{'ImageDescription'});
		
		#Write new value
		$exifTool->WriteInfo($filename);
		
	    }   
	} else {
	    print "ImageDescription Tag present\n";
	} 
    }
       
    exit 1;
}

#-----------------------------------------------------------------------------
sub setDescription {
    
    @oldDescription = ("ImageDescription");

}

#-----------------------------------------------------------------------------
sub readDescription {
    my $file = shift;
    
    my $fh = new FileHandle();
    $fh->open($file);
    
    while( not($fh->eof()) ) {
	my $line = $fh->getline();
	my ($filename, $description) = split(/\t/, $line);

	$imageDescription{ $filename } =
	{
            ImageDescription   => $description,
	};
    }
}
