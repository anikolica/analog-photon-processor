set prid [fork]
switch $prid {
    -1 {
        puts "Fork attempt failed."
		source ../scripts/drc.tcl
		source ../scripts/lvs.tcl
    }
    0 {
        puts "I am child process."
		source ../scripts/drc.tcl
    }
    default {
        puts "I am parent process. Child process is #$prid."
		source ../scripts/lvs.tcl
    }
}
#wait
loadViolationReport -type Calibre -filename DRC/calibre.drc.results
exec tail -5 LVS/[dbGet top.name].csm  >@stdout
