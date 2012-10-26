#!/usr/bin/perl -w
use warnings;
use Term::Cap;

$bound=10;
$iterations=1000;
$terminal = Term::Cap->Tgetent( { OSPEED => 9600 } );
$clear_string = $terminal->Tputs('cl');
$seedValue=0;

sub printArray{
	#output
	my $bound = int($_[0]);
	print "  ";
	for($upperLine=0;$upperLine<$bound;$upperLine++){
		print "_ ";
	}
	print "\n";
	for($i=0;$i<$bound;$i++){
		print "| ";
			for($j=0;$j<$bound;$j++){
				if($lifearray[$i][$j]==1){
					print  "# ";
				}
				else{
					print "  ";
				}
			}
		print " |\n";	
	}
	print "  ";
	for($lowerLine=0;$lowerLine<$bound;$lowerLine++){
		print "_ ";
	}
	print "  \n";
	print "Lifecount: ",$overallLifeCount,"\n";
}

sub initArray{
	#create playground

	$bound = $_[0];
	my $seedValue = int($_[1]);
	if($seedValue <0 || $seedValue>10){
		$seedValue=5;
	} else{
		$seedValue=$seedValue*10;
	}
	for(my $i=0;$i<$bound;$i++){
		#create random numbers to locate nice locations for some live
		for($randCounter=0;$randCounter<$bound;$randCounter++){
			$randArray[$randCounter]=int(rand(110));
		}
		for($j=0;$j<$bound;$j++){
			if($randArray[$j]<$seedValue){
					$lifearray[$i][$j]=1;
					$overallLifeCount++;
			}
			else{
				$lifearray[$i][$j]=0;
				#print "[",$i,"],[",$j,"]\n";
			}
		}	
}

sub checkForLife{
	#count surrounding life
	my $xCoord=$_[0];
	my $yCoord=$_[1];

	my $lifeCount = 0;
	
	if($yCoord>0){
		$upOK=1;
	}else{
		$upOK=0;
	}
	
	if($xCoord>0){
		$leftOK=1;
	} else{
		$leftOK=0;
	}

	if($yCoord<$bound-1){
		$downOK=1;
	}else{
		$downOK=0;
	}
	if($xCoord<$bound-1){
		$rightOK=1;
	} else{
		$rightOK=0;
	}

	#print "Check for life at ",$xCoord,"|",$yCoord,"\n";
	
	if($leftOK){
		#left side
		if($lifearray[$xCoord-1][$yCoord]>0){
			$lifeCount++;
		}
		if($upOK){
			if($lifearray[$xCoord-1][$yCoord-1]>0){
				$lifeCount++;
			}
		}
		if($downOK){
			if($lifearray[$xCoord-1][$yCoord+1]>0){
				$lifeCount++;
			}
		}
	}
	if($rightOK){
		#right side
		if($lifearray[$xCoord+1][$yCoord]>0){
			$lifeCount++;
		}
		if($upOK){
			if($lifearray[$xCoord+1][$yCoord-1]>0){
				$lifeCount++;
			}
		}
		if($downOK){
			if($lifearray[$xCoord+1][$yCoord+1]>0){
				$lifeCount++;
			}
		}	
	}
	if($upOK){
		#upper side
		if($lifearray[$xCoord][$yCoord-1]>0){
			$lifeCount++;
		}
	}
	if($downOK){
		#upper side
		if($lifearray[$xCoord][$yCoord+1]>0){
			$lifeCount++;
		}
	}

	return $lifeCount;
}

sub iterate{
	#calculate one row, save, calculate next row, save last row to lifearray
	@tempLine=0;
	$overallLifeCount=0;
	for(my $j=0;$j<$bound;$j++){
		$tempLine[0][$j]=0;
		$tempLine[1][$j]=0;
	}
	$saveLineSwitch=0;

	for($line=0;$line<$bound;$line++){
		if($line>1){
			for($n=0;$n<$bound;$n++){
				$lifearray[$line-2][$n]=$tempLine[$saveLineSwitch][$n];
			}
		}

		for($column=0;$column<$bound;$column++){
			my $tempLifeCount = checkForLife($line,$column);

			if($lifearray[$line][$column]==0 && $tempLifeCount==3){
				#new life
				$tempLine[$saveLineSwitch][$column]=1;
				$overallLifeCount++;
			} elsif($tempLifeCount<2 && $lifearray[$line][$column]==1){
				#death
				$tempLine[$saveLineSwitch][$column]=0;
			} elsif(($tempLifeCount==2 || $tempLifeCount==3) && $lifearray[$line][$column]==1){
				#life goes on
				$tempLine[$saveLineSwitch][$column]=1;
				$overallLifeCount++;
			} elsif($tempLifeCount>3){
				#death
				$tempLine[$saveLineSwitch][$column]=0;
				
			}
		}

		$saveLineSwitch=($saveLineSwitch+1)%2;

	}
	#write last two lines
	for($lastTwoLinesCount=0;$lastTwoLinesCount<$bound;$lastTwoLinesCount++){
		$lifearray[$bound-2][$lastTwoLinesCount]=$tempLine[0][$lastTwoLinesCount];
		$lifearray[$bound-1][$lastTwoLinesCount]=$tempLine[1][$lastTwoLinesCount];	
	}


}

sub debugLifearray{
	print "debugArray? [y/n]\n";
	$debugAnswer = <STDIN>;
	$debugAnswer =~ s/\R//g;
	print "answer: ->", $debugAnswer,"<-\n";
	if(($debugAnswer eq 'Y ') || ($debugAnswer eq 'y')){
		print "xCoord: \n";
		$xCoordAnswer = <STDIN>;
		$xCoordAnswer =~ s/\R//g;
		print "yCoord: \n";
		$yCoordAnswer = <STDIN>;
		$yCoordAnswer =~ s/\R//g;
		print "lifecount: ", checkForLife($yCoordAnswer,$xCoordAnswer),"\n";

	}
}

sub main{
	print $clear_string;
	$overallLifeCount=0;

	#user input
	print "edge length: ";
	$bound = <STDIN>;
	print "iterations [in thousands]: ";
	$iterations = <STDIN>;
	print "seed value [1-10]:";
	$seedValue = <STDIN>;
	print "display [Hz]";
	$hz = <STDIN>;

	#getting rid of linebreaks
	$bound =~ s/\R//g;
	$iterations =~ s/\R//g;
	$seedValue =~ s/\R//g;
	$hz =~ s/\R//g;


	$iterations = 1000 * $iterations;
	
	#no division by 0, mister!
	if($hz!=0){
		$hz = 1/$hz;
	} else{
		$hz = 1/5;
	}
	#chage bound limit for badass screens and computers
	if($bound>100){
		$bound=100;
	}
	$maxLiveCount = $bound*$bound;
	$boundRoot = $bound/$bound;
	@liveCountHistory = (0,0,1);


	initArray($bound, $seedValue);
	printArray($bound);
	print "start [press enter]\n";
	$dummyCheck=<STDIN>;
	print $clear_string;

	for($itCount=0;$itCount<$iterations;$itCount++){
		iterate();
		print $itCount+1,"/",$iterations," generation:\n";
		printArray($bound);
		#debugLifearray();
		#$dummyCheck=<STDIN>;
		
		#end conditions: death or stuck for three generations
		if($overallLifeCount<1 || $overallLifeCount==$maxLiveCount){
			print "death in the ",$itCount,". generation\n";
			$itCount=$iterations;
		}elsif($overallLifeCount < $boundRoot && $liveCountHistory[0] == $liveCountHistory[1] && $liveCountHistory[1] == $liveCountHistory[2]){
			print "stuck in the ",$itCount,". generation\n";
			$itCount=$iterations;
		}
		else{
			sleep($hz);
			$liveCountHistory[0]=$liveCountHistory[1];
			$liveCountHistory[1]=$liveCountHistory[2];
			$liveCountHistory[2]=$overallLifeCount;
			print $clear_string;
		}
	}	
	$dummyCheck=0;

}

}
&main