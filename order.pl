#!/usr/bin/env perl
use strict;
use warnings;
use Carp;
use Win32::OLE qw/EVENTS/;

my $XASession = Win32::OLE->new('XA_Session.XASession')
    or croak Win32::OLE->LastError();

my $XASessionEvents = sub {
    my ($obj, $event, @args) = @_;
    
    # 1: OnLogin, 2: OnLogout, 3: OnDisconnect
    if ($event == 1) {
	my ($code, $msg) = @args;
	print "XASession Login Event: [$code] $msg \n";
	Win32::OLE->QuitMessageLoop();
    } elsif ($event ==2) {
	print "XASession Logout Event: @args \n";
	Win32::OLE->QuitMessageLoop();
    } elsif ($event == 3) {
	print "XASession Disconnect Event: @args \n";
	Win32::OLE->QuitMessageLoop();
    }
};

Win32::OLE->WithEvents($XASession, $XASessionEvents,
		       '{6D45238D-A5EB-4413-907A-9EA14D046FE5}');

croak Win32::OLE->LastError() if Win32::OLE->LastError() != 0;

my $server  = 'demo.etrade.co.kr';	# 모의 투자 서버 주소
my $port    = 20001;			# 서비스 포트
my $user    = '';       		# 이트레이드 증권 아이디
my $pass    = '';	        	# 이트레이드 증권 암호
my $certpwd = '';			# 공인 인증서 암호
my $srvtype = 1;			# 서버 타입
my $showcerterr = 1;                 # 공인 인증서 에러

$XASession->ConnectServer($server, $port)
    or croak $XASession->GetErrorMessage( $XASession->GetLastError );

$XASession->Login($user, $pass, $certpwd, $srvtype, $showcerterr)
   or croak $XASession->GetErrorMessage( $XASession->GetLastError );

Win32::OLE->MessageLoop();

my $XAQuery  = Win32::OLE->new('XA_DataSet.XAQuery')
    or croak Win32::OLE->LastError();

$XAQuery->LoadFromResFile("$FindBin::Bin/res/Tran/t5501.res")
    or croak Win32::OLE->LastError();

my $XAQueryEvents = sub { };

$XAQuery->SetFieldData('t5501InBlock', 'reccnt',      0, '1');
$XAQuery->SetFieldData('t5501InBlock', 'accno',       0, 'XXXXXXXXXXX'); 
$XAQuery->SetFieldData('t5501InBlock', 'passwd',      0, '0000');
$XAQuery->SetFieldData('t5501InBlock', 'expcode',     0, 'A000270');
$XAQuery->SetFieldData('t5501InBlock', 'qty',         0, '1');
$XAQuery->SetFieldData('t5501InBlock', 'price',       0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'memegb',      0, '2');
$XAQuery->SetFieldData('t5501InBlock', 'hogagb',      0, '03');
$XAQuery->SetFieldData('t5501InBlock', 'pgmtype',     0, '00');
$XAQuery->SetFieldData('t5501InBlock', 'gongtype',    0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'gonghoga',    0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'tongsingb',   0, '00');
$XAQuery->SetFieldData('t5501InBlock', 'sinmemecode', 0, '000');
$XAQuery->SetFieldData('t5501InBlock', 'loandt',      0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'memnumber',   0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'ordcondgb',   0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'stragb',      0, '000000');
$XAQuery->SetFieldData('t5501InBlock', 'groupid',     0, '00000000000000000000');
$XAQuery->SetFieldData('t5501InBlock', 'ordernum',    0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'portnum',     0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'basketnum',   0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'tranchnum',   0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'itemnum',     0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'operordnum',  0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'flowsupgb',   0, '0');
$XAQuery->SetFieldData('t5501InBlock', 'oppbuygb',    0, '0');

$XAQuery->Request(0);

my $XAReal = Win32::OLE->new('XA_DataSet.XAReal.1')
    or croak Win32::OLE->LastError();

$XAReal->LoadFromResFile("$FindBin::Bin/res/Real/SC0_.res")
    or croak Win32::OLE->LastError();

my $XARealEvents = sub {
    my ($obj) = @_;

    print $obj->GetFieldData('OutBlock', 'ordno'), "\n";
};

Win32::OLE->WithEvents($XAReal, $XARealEvents, '{16602768-2C96-4D93-984B-E36E7E35BFBE}');
croak Win32::OLE->LastError() if Win32::OLE->LastError() != 0;

$XAReal->AdviseRealData();

Win32::OLE->MessageLoop();
