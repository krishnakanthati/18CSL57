set ns [new Simulator]

set ntrace [open pg02.tr w]
$ns trace-all $ntrace

set namfile [open pg02.nam w]
$ns namtrace-all $namfile

proc Finish {} {
    global ns ntrace namfile
    $ns flush-trace
    close $ntrace
    close $namfile
    exec nam pg02.nam &
    puts "the numbers of ping packets dropped are"
    exec grep "^d" pg02.tr | cut -d " " -f 5 | grep -c "ping" &
    exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n0 $n1 0.1Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.1Mb 10ms DropTail
$ns duplex-link $n2 $n3 0.1Mb 10ms DropTail
$ns duplex-link $n3 $n4 0.1Mb 10ms DropTail
$ns duplex-link $n4 $n5 0.1Mb 10ms DropTail

Agent/Ping instproc recv {from rtt} {
 $self instvar node_
 puts "node [$node_ id] received ping answer from $from with round trip time $rtt ms"
}

set p0 [new Agent/Ping]
$ns attach-agent $n0 $p0
set p1 [new Agent/Ping]
$ns attach-agent $n5 $p1
$ns connect $p0 $p1

$ns queue-limit $n0 $n1 2

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n5 $sink0
$ns connect $tcp0 $sink0

set ftp0 [new Application/FTP]
$ftp0 set packetSize_ 500
$ftp0 attach-agent $tcp0

$ns at 0.2 "$p0 send"
$ns at 0.4 "$p1 send"
$ns at 0.4 "$ftp0 start"
$ns at 0.8 "$p0 send"
$ns at 1.0 "$p1 send"
$ns at 1.2 "$ftp0 stop"
$ns at 1.4 "$p0 send"
$ns at 1.6 "$p1 send"
$ns at 1.8 "Finish"

$ns run
