set ns [new Simulator]

set nt [open pg03.tr w]
$ns trace-all $nt

set na [open pg03.nam w]
$ns namtrace-all $na

set ng1 [open tcp1.xg w]
set ng2 [open tcp2.xg w]

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns make-lan "$n0 $n1 $n2" 1Mb 10ms LL Queue/DropTail Mac/802_3
$ns make-lan "$n5 $n4 $n3" 1Mb 10ms LL Queue/DropTail Mac/802_3
$ns duplex-link $n0 $n5 1Mb 10ms DropTail

set tcp1 [new Agent/TCP]
set tcp2 [new Agent/TCP]
set ftp1 [new Application/FTP]
set ftp2 [new Application/FTP]

$ns attach-agent $n4 $tcp1
$ftp1 attach-agent $tcp1
$ns attach-agent $n1 $tcp2
$ftp2 attach-agent $tcp2

set sink1 [new Agent/TCPSink]
set sink2 [new Agent/TCPSink]

$ns attach-agent $n2 $sink1
$ns attach-agent $n5 $sink2

$ns connect $tcp1 $sink1
$ns connect $tcp2 $sink2

$tcp1 set class_ 1
$tcp2 set class_ 2

proc Finish {} {
    global ns na nt
    $ns flush-trace
    close $na
    close $nt 
    exec nam pg03.nam &
    exec xgraph tcp1.xg tcp2.xg &
    exit 0
}

proc Draw {Agent File} {
    global ns
    set Cong [$Agent set cwnd_]
    set Time [$ns now]
    puts $File "$Time $Cong"
    $ns at [expr $Time+0.01] "Draw $Agent $File"
}

$ns at 0.0 "$ftp1 start"
$ns at 0.7 "$ftp2 start"
$ns at 0.0 "Draw $tcp1 $ng1"
$ns at 0.0 "Draw $tcp2 $ng2"
$ns at 10.0 "Finish"

$ns run