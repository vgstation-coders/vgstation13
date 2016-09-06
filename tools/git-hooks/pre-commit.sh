#!/bin/sh
#Test comment 9

echo "Doing something"
for SCRIPT in /pre-commit-hooks/*
do
	if [ -f $SCRIPT -a -x $SCRIPT ]
	then
		$SCRIPT
	fi
done

exit 1
