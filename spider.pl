#!/usr/bin/perl

use strict;

use URI::URL;
use Getopt::Long;
use LWP::UserAgent;

my $site = $ARGV[0];
my %options = ();
GetOptions (\%options, "p=s", "w=s");

print q {
================================================================================

# title:        Very Raw Web Spider
# developer:     code91
# e-mail:        < code[at]insicuri[dot]net >

# release date:  2008-04-01 (ISO 8601) 

Usage:
         perl spider.pl [site] {options}

Options:
         -p [ip:port] scan with proxy support.
         -w [path] write results on a file.      

================================================================================
};

if( !$site )
{
        exit;
}

my $ua = LWP::UserAgent->new();
       
print "\n[+] Performing url...\n";
if( $site !~ /http:\/\// )
{
        $site = "http://".$site;
}

if( $options{"p"} )
{        
        $ua->proxy( 'http', "http://".$options{"p"} );
        print "[+] Scanning with proxy...\n";
}
else
{
        $ua->no_proxy( '127.0.0.1' );
        print "[+] Scanning w/out proxy...\n";
}

print "[+] Getting source...\n";           
my $response = $ua->get( $site ) or die ( "[-] Unable to connect $site.\n" );
my $results  = $response->content();

print "[+] Parsing html source...\n\n";

my( $title, $description, $content, @sites );

if( $results =~ m/<title>(.*?)<\/title>/i )
{
        $title = $1;
        print "[+] Title: $title\n";
}
                                               
if( $results =~ m/<meta name=\"description\" content=\"(.*?)\">/i )
{
        $description = $1;
        print "[+] Info: $description\n";
}

while( $results =~ m/<a href=\"(.*?)\">/gi ) # collecting links from img srcs...
{
        $content = $1;
        push( @sites, $content );
}

my( @links, @imgs, @mails, @md5s );
foreach $content( @sites )
{      
        if( $content =~ m/http:\/\//gi )
        {
                process_url( $content );
                push( @links, " - $content\r\n" );
        }
}                                              
                                               
while( $results =~ m/<img src=\"(.*?)\">/gi ) # collecting links from img srcs...
{
        $content = $1;
        push ( @imgs, $content );  
}      
foreach $content( @imgs )
{
        if( $content =~ m/http:\/\//gi )
        {
                process_url( $content );
                push( @links, " - $content\r\n" );
        }
}  
                                               
while( $results =~ m/([a-zA-Z0-9_\.]+@[a-zA-Z0-9-]+\.[a-zA-Z]{0,15})/g ) # collecting mails...
{
        push( @mails, " - $1\r\n" );
}  

while( $results =~ m/([a-f0-9]{32})/g ) # collecting md5 hashes...  
{
        push( @md5s, " - $1\r\n");
}                                                                                                                                                                                                                

if( @links || @mails || @md5s )
{
        print "[+] $#links links found: \n @links \n" if( @links );
        print "[+] $#mails mails found: \n @mails \n" if( @mails );
        print "[+] $#md5s md5 found: \n @md5s \n" if( @md5s );
        if( $options{"w"} )
        {
                print "[+] Writing results in $options{'w'}...\n";     
                open( FILE, ">", $options{'w'} ) or die( "[-] Unable to open file in <$options{'w'}> path.\n" );
                print FILE "@links\n @mails\n @md5s\n";
                close( FILE );
                print "[+] Ended.\n\n";
        }  
}
else
{
        print "[-] No links, md5s, mails addresses found. \n";
}                                                                                                                                                                                                                      
                                                   
sub process_url( $ )
{
        my $uri = URI::URL->new( $content );
        $content = $uri->host();
        if ( $content !~ /http:\/\// )
        {
                $content = "http://".$content;
        }
}

