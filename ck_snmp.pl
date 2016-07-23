#!/usr/bin/perl -w
use strict;
use warnings;

my $DUPLICATED_REQSTID=2;

my %rqstId=();
my @snmpCmd=(
			'get-request',
			'set-request',
			'get-next-request',
			'getBulkRequest',
			'snmpV2-trap',			
			'get-response',			
		);
my $reqestId="";
my $snmpAction="";		
		
while (<>)
{
    if(/\s+data\:\s(\w+)\s\(\d\)/ || /\s+data\:\s(\w+\-\w+)\s\(\d+\)/ || /\s+data\:\s(\w+\-\w+\-\w+)\s\(\d+\)/)
    {
        $snmpAction = $1;
    }
    if(/\s+request\-id\:\s(\d+)$/)
    {
        $reqestId=$1;
    }
    if(/No\.\s+Time/)
    {
        if(($reqestId ne "") && ($snmpAction ne ""))
        {
            if(defined $rqstId{$reqestId}{$snmpAction})
            {
                $rqstId{$reqestId}{$snmpAction}++;
            }else
            {
                 $rqstId{$reqestId}{$snmpAction}=1;
            }
        }
        $reqestId="";
        $snmpAction="";
    }		
}

printf "%10s %3s %3s %3s %3s %3s %3s\n","Reqest_id","get","set","nxt","blk","trp","rsp";
foreach my $rqid(sort{$a<=>$b}  keys %rqstId)
{
    my $errFlag=0;
    my $line=sprintf("%10s ",$rqid);
    for(my $i=0;$i<6;$i++)
    {
        if(defined $rqstId{$rqid}{$snmpCmd[$i]})
        {
            $line=$line.sprintf( "%3s ",$rqstId{$rqid}{$snmpCmd[$i]});
            $errFlag++ if($rqstId{$rqid}{$snmpCmd[$i]}>=$DUPLICATED_REQSTID);
        }else
        {
            $line=$line.sprintf("%3s ","0");
        }
    }
    $line=$line.sprintf("\n");
    print $line if($errFlag);	
}
