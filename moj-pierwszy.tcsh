#!/bin/tcsh
#Przemysław Pawlik

foreach arg ( $argv )
    if ( "$arg" == "-h" || "$arg" == "--help" ) then
        echo "This script shows user full name if it is available"
        echo "Usage: ./`basename $0` [OPTIONS]"
        echo "OPTIONS:"
        echo "  -h, --help     Show this help message"
        echo "  -q, --quiet    Finish without work"
        exit 0
    endif
end

foreach arg ( $argv )
    if ( "$arg" == "-q" || "$arg" ==  "--quiet" ) then
        exit 0
    endif
end

set NAME = `getent passwd $USER | cut -d: -f5 | cut -d, -f1`

if ( "$NAME" == "" ) then
    echo "User info is not available"
    exit 0
else
    echo $NAME
    exit 1
endif
