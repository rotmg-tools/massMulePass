#!/usr/bin/perl -w
#
# mass mule password changer (c) supahacka@gmail.com
# v0.2
#

use strict;
use warnings;
use threads;
use Thread::Queue;
my $q = Thread::Queue->new(); # A new empty queue

die 'Please specify the new password as a command line argument.' if !defined $ARGV[0];
my $newPassword=$ARGV[0];

open(INPUT,'mules.txt') or die 'Can not open input file "mules.txt": ' . $! . "\n";
while(<INPUT>){
 chomp();
 my($guid,$password)=split(/\s+/,$_);
 $q->enqueue([$guid, $password, $newPassword]);
}
print $q->pending() . ' mules queued for processing.' . "\n";
sleep 2;

sub start_thread {
 while(my $mule=$q->dequeue_nb()){
  # Format:
  # POST https://realmofthemadgod.appspot.com/account/changePassword
  # URLEncoded form
  # guid:         foo@foo.org
  # ignore:       79341
  # newPassword:  futloch2
  # password:     futloch
 
  my $content = [
 	'guid' => $mule->[0],
 	'ignore' => int(rand(1000)+1000),
 	'newPassword' => $mule->[2],
 	'password' => $mule->[1],
  ];
 
  use LWP::UserAgent;
  use HTTP::Request::Common qw(POST);
  my $ua = LWP::UserAgent->new;
  
  my $retry=1;
  my $timesTried=0;
  my $result=undef;
  while($retry==1){
   my $req = POST 'http://realmofthemadgod.appspot.com/account/changePassword', $content;
   my $res = $ua->request($req);
   $result=$res->decoded_content;
   $timesTried++;
   $retry=0 if ($result eq '<Success/>' || $timesTried>=2);
   print 'Change password for mule ' . $mule->[0] . '/' . $mule->[1] . ' to ' . $mule->[2] . ' - result: ' . $result . ($timesTried>1 ? ' (retry #' . $timesTried .' )' : '') . "\n";
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