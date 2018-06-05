#!/bin/bash
#Launch this bash using "bash bash.sh"

# AUTHOR: BENJAMIN LEVY
# CONTACT : BENJAMINLEVYPRO@GMAIL.COM OR GITHUB BENJILEV92
# RELEASE DATE: 30/05/2018
# YOU CAN RE-USE THIS FILE BUT DON'T FORGET TO LINK
# THE FOLLOWING WEBSITE AND THE AUTHOR
# https://github.com/benjilev92


Reset=$(sudo hciconfig hci0 reset) >> ./DOC/ErrorWarnings.log 2>&1
if [ "$Reset" = "" ]; then
	echo "HCI0 reseted"
else
	echo "Please check HCI config for reset, problem occured\nExiting ..."
	exit 1
fi
sudo hciconfig hci0 down
printf "bluetooth is "
sudo hciconfig status | sed -n 3p
sudo hciconfig hci0 up
printf "bluetooth is "
sudo hciconfig status | sed -n 3p



turn=0
date=$( date '+%d%B%y__%Hh%Mm%Ss' )
a="_exec"
b="_on_"
mkdir DOC CONFIG DOC/DATA DOC/IMG DOC/OUTPUT >> ./DOC/ErrorWarnings.log 2>&1
if [ -z "$1" ]
then 
	numberOfExecution=6
	name="$numberOfExecution$a$b$date"
else
	numberOfExecution=$1
	name="$numberOfExecution$a$b$date"
fi
numberOfExecution=$(( numberOfExecution * 2 ))

if [ -z "$2" ]
then 
	TimeOfExecution=2

else
	TimeOfExecution=$2
fi

for (( j=2; j <= $numberOfExecution; j+=2 ))
do
turn=$((turn +1))
echo loop $turn
	#opération
	
	sudo timeout $TimeOfExecution python3.5 -m aioblescan -r | grep Weather | head -n 1 >> ./DOC/OUTPUT/TEXT_OUTPUT
	[ -s ./DOC/OUTPUT/TEXT_OUTPUT ] || echo "no data incomming"
	
	#enlever tout ce dont on a pas besoin
	
	tr -d "'" < ./DOC/OUTPUT/TEXT_OUTPUT > ./DOC/OUTPUT/TREATED_OUTPUT
	tr -d ":" < ./DOC/OUTPUT/TREATED_OUTPUT > ./DOC/OUTPUT/TEXT_OUTPUT
	tr -d "{" < ./DOC/OUTPUT/TEXT_OUTPUT > ./DOC/OUTPUT/TREATED_OUTPUT
	tr -d "}" < ./DOC/OUTPUT/TREATED_OUTPUT > ./DOC/OUTPUT/TEXT_OUTPUT
	tr -d "," < ./DOC/OUTPUT/TEXT_OUTPUT > ./DOC/OUTPUT/TREATED_OUTPUT
	sed 's/Weather//;s/info//;s/mac /mac_/' ./DOC/OUTPUT/TREATED_OUTPUT > ./DOC/OUTPUT/TEXT_OUTPUT
	nl  ./DOC/OUTPUT/TEXT_OUTPUT > ./DOC/OUTPUT/FINAL_OUTPUT
	
	line=$( tail -n 1 ./DOC/OUTPUT/FINAL_OUTPUT)
	string=($line)
	
	for (( i=2; i < 14; i+=2 ))
	do
		sudo echo $turn ${string[$i]} >> ./DOC/DATA/${string[$i-1]}.data
	done
done

if (( $numberOfExecution > 300 ))
then
	gnuplot -e "load \"./CONFIG/rssi.config\"" >> ./DOC/ErrorWarnings.log 2>&1
	gnuplot -e "load \"./CONFIG/humidity.config\"" >> ./DOC/ErrorWarnings.log 2>&1
	gnuplot -e "load \"./CONFIG/pressure.config\"" >> ./DOC/ErrorWarnings.log 2>&1
	gnuplot -e "load \"./CONFIG/temperature.config\"" >> ./DOC/ErrorWarnings.log 2>&1
	gnuplot -e "load \"./CONFIG/tx_power.config\"" >> ./DOC/ErrorWarnings.log 2>&1
else

gnuplot -e "load \"./CONFIG/wprssi.config\"" >> ./DOC/ErrorWarnings.log 2>&1
gnuplot -e "load \"./CONFIG/wphumidity.config\"" >> ./DOC/ErrorWarnings.log 2>&1
gnuplot -e "load \"./CONFIG/wppressure.config\"" >> ./DOC/ErrorWarnings.log 2>&1
gnuplot -e "load \"./CONFIG/wptemperature.config\"" >> ./DOC/ErrorWarnings.log 2>&1
gnuplot -e "load \"./CONFIG/wptx_power.config\"" >> ./DOC/ErrorWarnings.log 2>&1
fi
cd ./DOC

mkdir $name
mv DATA ./$name
mv IMG ./$name
mv OUTPUT ./$name
mv ErrorWarnings.log ./$name
cd ..


