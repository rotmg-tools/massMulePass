#!/usr/bin/perl -w
#
# mass mule register
# based on mass mule password changer v0.2 (c) supahacka@gmail.com
# 
#

# perl massMuleRegister.pl foo%%%%%@example.com password 10
# email, password, mule count

use strict;
use warnings;
use threads;
use Thread::Queue;
my $q = Thread::Queue->new(); # A new empty queue

die 'Please specify the email pattern as a command line argument.' if !defined $ARGV[0];
die 'Please specify the password as a command line argument.' if !defined $ARGV[1];
die 'Please specify the number of mules pattern as a command line argument.' if !defined $ARGV[2];
my $guid=$ARGV[0];
my $newPassword=$ARGV[1];
my $muleCount=$ARGV[2];


my $outfile = "mules.txt";

open (MYFILE, ">$outfile") or die 'Can not open output file "mules.txt": ' . $! . "\n";



$q->enqueue([$guid, $newPassword]);



print $q->pending() . ' mules queued for register.' . "\n";
sleep 2;

sub start_thread {
 while(my $mule=$q->dequeue_nb()){
  # Format:
  # POST https://realmofthemadgod.appspot.com/account/register
  # URLEncoded form
  # guid:         foo@foo.org
  # ignore:       79341
  # newPassword:  futloch2
 
  my $content = [

  'guid'=> 'DDDDDDDD30A5B289EA856859A8',
 	'newGUID' => $mule->[0],
 	'ignore' => int(rand(1000)+1000),
  
 	'newPassword' => $mule->[1],
  'isAgeVerified' => 1,
  ];
 
  use LWP::UserAgent;
  use HTTP::Request::Common qw(POST);
  my $ua = LWP::UserAgent->new;
  
  my $retry=1;
  my $timesTried=0;
  my $result=undef;
  while($retry==1){
   my $req = POST 'http://realmofthemadgod.appspot.com/account/register', $content;
   my $res = $ua->request($req);
   $result=$res->decoded_content;
   $timesTried++;
   $retry=0 if ($result eq '<Success/>' || $timesTried>=2);

   print 'register mule: ' . $mule->[0] . 'password: ' . $mule->[1] .' - result: ' . $result . ($timesTried>1 ? ' (retry #' . $timesTried .' )' : '') . "\n";

  }
 }
}

for(0..2){
 my $thr = threads->create('start_thread');
}

while(threads->list(threads::running)){
 print scalar(localtime(time())) . ' # of threads running: ' . scalar(threads->list(threads::running)) . "\n";
 print $q->pending() . ' mules queued for processing.' . "\n";
 sleep 5;
}

foreach (threads->list(threads::joinable)){
 $_->join();
}

close (MYFILE); 
