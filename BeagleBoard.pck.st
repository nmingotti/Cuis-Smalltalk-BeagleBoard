'From Cuis 5.0 [latest update: #4885] on 8 January 2022 at 12:26:20 am'!
'Description '!
!provides: 'BeagleBoard' 1 14!
!requires: 'Cuis-Base' 50 4885 nil!
!requires: 'CommandShell' 1 2 nil!
!requires: 'Regex' 1 5 nil!
!requires: 'OSProcess' 1 17 nil!
SystemOrganization addCategory: #BeagleBoard!
SystemOrganization addCategory: #'BeagleBoard-BB-AI'!
SystemOrganization addCategory: #'BeagleBoard-Examples'!


!classDefinition: #BB_README category: #BeagleBoard!
Object subclass: #BB_README
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard'!
!classDefinition: 'BB_README class' category: #BeagleBoard!
BB_README class
	instanceVariableNames: ''!

!classDefinition: #Pin category: #BeagleBoard!
Object subclass: #Pin
	instanceVariableNames: 'header position'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard'!
!classDefinition: 'Pin class' category: #BeagleBoard!
Pin class
	instanceVariableNames: ''!

!classDefinition: #Gpio category: #BeagleBoard!
Pin subclass: #Gpio
	instanceVariableNames: 'sysfsDirectory'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard'!
!classDefinition: 'Gpio class' category: #BeagleBoard!
Gpio class
	instanceVariableNames: ''!

!classDefinition: #GpioOut category: #BeagleBoard!
Gpio subclass: #GpioOut
	instanceVariableNames: 'pull status'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard'!
!classDefinition: 'GpioOut class' category: #BeagleBoard!
GpioOut class
	instanceVariableNames: ''!

!classDefinition: #PWM category: #'BeagleBoard-BB-AI'!
Object subclass: #PWM
	instanceVariableNames: 'sysfsDir enableFile periodFile dutyCycleFile defaultDutyCycle'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard-BB-AI'!
!classDefinition: 'PWM class' category: #'BeagleBoard-BB-AI'!
PWM class
	instanceVariableNames: ''!

!classDefinition: #FanCape category: #'BeagleBoard-BB-AI'!
PWM subclass: #FanCape
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard-BB-AI'!
!classDefinition: 'FanCape class' category: #'BeagleBoard-BB-AI'!
FanCape class
	instanceVariableNames: ''!

!classDefinition: #Temperature category: #'BeagleBoard-BB-AI'!
Object subclass: #Temperature
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard-BB-AI'!
!classDefinition: 'Temperature class' category: #'BeagleBoard-BB-AI'!
Temperature class
	instanceVariableNames: ''!

!classDefinition: #BBExamples category: #'BeagleBoard-Examples'!
Object subclass: #BBExamples
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard-Examples'!
!classDefinition: 'BBExamples class' category: #'BeagleBoard-Examples'!
BBExamples class
	instanceVariableNames: ''!


!Pin commentStamp: '<historical>' prior: 0!
Documentation placeholder 
!

!Gpio commentStamp: '<historical>' prior: 0!
I provide services to all GPIO pins. Dont' instantiate me. !

!GpioOut commentStamp: '<historical>' prior: 0!
I am a digital output pin. 
. To define one instance of me on a given position, say "P9_14" you must know for sure i can stay there.
. If you want me to be a defalt #off pin then select pull:#down, otherwise pull:#up on the contructor.  
. All gpio output ping are initialized by defaut to status corresponded to their pull resistors, that 
  is a pullDown is set to off and a pullUp is set to #on .
=== iVar ==
pull : aSymbol | can be #up or #down 
status : aSymbol | can be #on or #off 
=========

== Example ===
. Create an instance of me as 
go1 _ GpioOut header: 9 position: 14 pull: #down.
. The you can read and change my state as 
go1 status     "=> #on or #off"
go1 on           " set my status to HIGH voltage "
go1 off           " set my status to LOW voltage "


!

!PWM commentStamp: '<historical>' prior: 0!
. A pwm pin is configured setting the value of 3 files in a specific directory
. The files are: enable, period, duty_cycle
. When universal_cape is not present the PWM must be set via overlays in /boot/uEnv.txt
. When the machine boots enable, perdio, and duty_cycle all contain the value '0'
--- Variables -------
sysfsDir --- DirectoryEntry --- directory of sysfs where we can control the PWM 
enableFile --- FileEntry  --- file 'enable'
periodFile --- FileEntry --- 
dutyCycleFile --- FileEntry ---
defaultDutyCycle --- Number --- value between 0 and 1, represent the default ratio duty/period when 
                                                   we set the PWM as a frequency and we don't specify the dutyCycle. 
                                                   by default this will be set to 0.5. 
---------------------------------------!

!FanCape commentStamp: '<historical>' prior: 0!
This are my setting for the fan cape where i have defined a few useful parameters to make it not loud if not necessary.
!

!Pin methodsFor: 'as yet unclassified' stamp: 'NM 12/5/2021 15:37:23'!
name
	". Return the pin name, e.g. P9_11. It means header 9 and position 11 over that header . 
	. This is the standard way of naming pings in the BeagleBoard. There exists other format as  'P9.11', 'p9_11' etc. "
	^ 'P{1}_{2}' format: {header. position.}.! !

!BB_README methodsFor: 'as yet unclassified' stamp: 'NM 1/8/2022 00:11:31'!
bbREADME

"
======  **IMPORTANT**. Writing to sysfs files.  ===============
. To control devices we use Linux files in sysfs, for example /dev/pww/ehrxxx/period 
. These files can not be deleted  => forceWriteStreamDo will not work
. There files are supposed to receive ASCII, not UTF-8, this in Python3 implies we need to
  write in 'binary' mode, in Cuis we can write in text mode since text here means Latin1. 
. The metod i found to write in these files is 'appendStreamDo', no newline is required, just write in the value
.===============================================




"! !

!Gpio methodsFor: 'accessing' stamp: 'NM 12/5/2021 16:32:24'!
sysfsDirectory
	". Accessor, return the direcotry used by Linux userland to control the gpio pin 
	. There will be only the reader, since this variable is set on gpio pin initialization 
	"
	^ sysfsDirectory ! !

!Gpio methodsFor: 'initialization' stamp: 'NM 12/5/2021 15:54:14'!
getSysfsDirectory
	" . When a pin is configured as GPIO it gets a directory in sysfs which permits the Linux 
	userland application to manupulate it through file operations. 
	. I find such directory, if it exists.
	. Example output: /sys/class/gpio/gpio241
	. Returns a DirectoryEntry object .
	"
	|gpDirList out |
	". all directories containing gpio pins "
	gpDirList _  '/sys/class/gpio' asDirectoryEntry directories select: [ :dir | dir asString matchesRegex: '.*gpio\d+' ] . 
	out _ nil.
	gpDirList do: [ :dir | |sysFile text|
		". get file content, something like 'P8_11' "
		sysFile _ (dir / 'label' ) asString asFileEntry.
		text _  sysFile fileContents withBlanksTrimmed . 
		(text = self name) ifTrue: [ out _ dir ].
		].
	". The sysfs file must be found, or something went wrong"
	self assert: (out notNil ).
	^ out! !

!GpioOut methodsFor: 'initialization' stamp: 'NM 12/5/2021 17:31:40'!
initializeAtHeader: anInteger1 position: anInteger2 pull: aSymbol
	|pullStr cmd ret|
	header _ anInteger1.
	position _ anInteger2. 
	pull _ aSymbol.
	". input check. 'pull' can be only #up or #down "
	self assert: ({#up. #down} includes: pull).
	". configure the pin as a gpio "
	(pull = #up) ifTrue: [pullStr _ 'gpio_pu' ]  ifFalse: [pullStr _ 'gpio_pd'].
	cmd _ 'config-pin P{1}_{2} {3}' format: {header. position. pullStr.}.
	ret _ PipeableOSProcess waitForCommand: cmd.
	self assert: (ret exitCode = 0).
	". store its sysfs directory. Requires 'header' and 'position' to be set. "
	sysfsDirectory _ self getSysfsDirectory .
	".  set gpio as an output pin, requires 'sysfsDirectory' to be set. "
	self setPinAsOutput .
	". we set the defult output pin value accordin to its pull(up|down) resistors "
	(pull = #down) ifTrue: [self off] ifFalse: [self on]. 
	
	! !

!GpioOut methodsFor: 'initialization' stamp: 'NM 12/5/2021 17:23:36'!
setPinAsOutput
	". turn the pin output to high voltage 
	"
	|sysfsFile|
	sysfsFile _ self sysfsDirectory / 'direction' :: asString asFileEntry.
	sysfsFile appendStreamDo: [ :st | st nextPutAll: 'out'  ]. 

	
	! !

!GpioOut methodsFor: 'operations' stamp: 'NM 12/5/2021 17:25:06'!
off
	". turn the pin output to high voltage 
	. NOTE. Observe we are using 'append' to write to the file.  'write' does not work, probably
	because it tries to remove thie files first.  
	"
	|sysfsFile|
	sysfsFile _ self sysfsDirectory / 'value' :: asString asFileEntry.
	sysfsFile appendStreamDo: [ :st | st nextPut: $0  ]. 
	status _ #off.
	
	! !

!GpioOut methodsFor: 'operations' stamp: 'NM 12/5/2021 17:24:37'!
on
	". turn the pin output to high voltage 
	. NOTE. Observe we are using 'append' to write to the file.  'write' does not work, probably
	because it tries to remove thie files first.  
	"
	|sysfsFile|
	sysfsFile _ self sysfsDirectory / 'value' :: asString asFileEntry.
	sysfsFile appendStreamDo: [ :st | st nextPut: $1  ]. 
	status _ #on.
	
	! !

!GpioOut methodsFor: 'operations' stamp: 'NM 12/5/2021 17:28:53'!
status
	". read the pin status
	. since this is an output pin it is supposed the status is known 
	"
	^ status ! !

!GpioOut class methodsFor: 'instance creation' stamp: 'NM 12/5/2021 17:34:35'!
newAtHeader: anInt1 position: anInt2 pull: aSymbol
	". anInt1 can be 8 or 9 in BeagleBone Black or AI
	. anInt2 can be a number over header8 or header9 respetively
	. pull can be #down or #up. If we set #down the pin is created in the 'off' state
	 otherwise in 'on' state.
	"
	^ self basicNew initializeAtHeader: anInt1 position: anInt2 pull: aSymbol  ! !

!PWM methodsFor: 'examples' stamp: 'NM 1/8/2022 00:26:06'!
example1
	"
	. TODO: check it works after system reboot 
	. TODO: check if the dutyCycle stend for the high part of the curve (seems the contrary now)
	. create a PWM pin and control it 
	"
	|p19|
	 p19 _ PWM newAt: '/dev/pwm/ehrpwm2a' .

	p19 getPeriodInNanoSec . 
	p19 getDutyCycleInNanoSec  . 

	p19 setFrequency: 2. 

	p19 enable. 

	p19 setFrequency: 5. 

	p19 setFrequency: 100.

	p19 setFrequency: 440.

	p19 disable. 
	
! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 12/30/2021 04:42:12'!
disable
	". disable the PWM unit "
	enableFile appendStreamDo: [ :str | str nextPut: $0 ]. 
	! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 1/7/2022 23:27:20'!
enable
	". enable the PWM unit "
	enableFile appendStreamDo: [ :str | str nextPut: $1 ]. 
	! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 1/7/2022 23:35:30'!
getDutyCycleAsPercent
	". return the duty cycle expressed as a percent value of the period. "
	^ (self getDutyCycleInNanoSec  / self getPeriodInNanoSec ) * 100.0 ! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 1/7/2022 23:33:28'!
getDutyCycleInNanoSec
	". returns the time duration of the duty cycle in nano seconds. 
	. this value must be always inferion to the value in 'periodNS' for things to make sense. "
	^ dutyCycleFile fileContents asNumber ! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 1/7/2022 23:33:55'!
getPeriodInNanoSec
	". returns the time duration of a single period of the pwm in nano seconds "
	^ periodFile fileContents asNumber ! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 1/7/2022 23:48:27'!
initializeAt: dirName
	". TODO: check the directory name esits and the file that must be there, if not, raise exception  
	. initialize the PWM at known values of period and duty cycle, by default it is in disabled state "
	sysfsDir _ dirName asDirectoryEntry .
	periodFile _ sysfsDir // 'period'  . 
	dutyCycleFile _  sysfsDir  // 'duty_cycle' .  
	enableFile _ sysfsDir // 'enable' . 
	". by default the duty cycle is 0.5 "
	defaultDutyCycle _ 0.5. 
	
	
	! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 12/30/2021 04:47:49'!
reset
	". disable the PWM unit , then duty cycle to zero, and period to 1_000 nano-seconds. It can't be 0."
	self disable.
	dutyCycleFile appendStreamDo: [ :str | str nextPutAll: '0' ].
	periodFile appendStreamDo: [ :str | str nextPutAll: '1000' ].	 
	! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 1/8/2022 00:12:47'!
setDutyCycleInNanoSec: aNumber
	dutyCycleFile appendStreamDo: [ :str | str nextPutAll: (aNumber asString) ] . 
	
	
	! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 1/8/2022 00:20:54'!
setFrequency: aNumberHz 
	".  This command sets the the frequency at a given Hz
	. accepted values (as of today) are > 1.1   
	"
	|periodNS dutyNS|
	". set to zero the dutyCycle so we can manuver on the period " 
	self setDutyCycleInNanoSec: 0.
	". compute values to be set  "  
	periodNS _ ( (1.0  / aNumberHz) * 1e9 )asInteger . 
	dutyNS _ (periodNS * defaultDutyCycle ) asInteger . 
	". set the values " 
	self setPeriodInNanoSec: periodNS . 
	self setDutyCycleInNanoSec: dutyNS . ! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 1/8/2022 00:12:23'!
setPeriodInNanoSec: aNumber
	periodFile appendStreamDo: [ :str | str nextPutAll: (aNumber asString) ] . 
	
	
	! !

!PWM methodsFor: 'as yet unclassified' stamp: 'NM 1/7/2022 23:30:42'!
status
	". check the status of the PWM, can return #on or #off "
	^ nil 
	! !

!PWM methodsFor: 'accessing' stamp: 'NM 1/7/2022 23:51:06'!
defaultDutyCycle
	"Answer the value of defaultDutyCycle"

	^ defaultDutyCycle! !

!PWM methodsFor: 'accessing' stamp: 'NM 1/7/2022 23:51:06'!
defaultDutyCycle: anObject
	"Set the value of defaultDutyCycle"

	defaultDutyCycle _ anObject! !

!PWM methodsFor: 'accessing' stamp: 'NM 1/7/2022 23:51:06'!
dutyCycleFile
	"Answer the value of dutyCycleFile"

	^ dutyCycleFile! !

!PWM methodsFor: 'accessing' stamp: 'NM 1/7/2022 23:51:06'!
dutyCycleFile: anObject
	"Set the value of dutyCycleFile"

	dutyCycleFile _ anObject! !

!PWM methodsFor: 'accessing' stamp: 'NM 1/7/2022 23:51:06'!
enableFile
	"Answer the value of enableFile"

	^ enableFile! !

!PWM methodsFor: 'accessing' stamp: 'NM 1/7/2022 23:51:06'!
enableFile: anObject
	"Set the value of enableFile"

	enableFile _ anObject! !

!PWM methodsFor: 'accessing' stamp: 'NM 1/7/2022 23:51:06'!
periodFile
	"Answer the value of periodFile"

	^ periodFile! !

!PWM methodsFor: 'accessing' stamp: 'NM 1/7/2022 23:51:06'!
periodFile: anObject
	"Set the value of periodFile"

	periodFile _ anObject! !

!PWM methodsFor: 'accessing' stamp: 'NM 1/7/2022 23:51:06'!
sysfsDir
	"Answer the value of sysfsDir"

	^ sysfsDir! !

!PWM methodsFor: 'accessing' stamp: 'NM 1/7/2022 23:51:06'!
sysfsDir: anObject
	"Set the value of sysfsDir"

	sysfsDir _ anObject! !

!PWM class methodsFor: 'as yet unclassified' stamp: 'NM 12/30/2021 04:32:36'!
newAt: dirName
	"Open a new PWM which is referenced by sysfs at the directory 'dirName' 
	. dirName : String . example: '/dev/pwm/ehrpwm1a '
	"
	^ self basicNew initializeAt: dirName
	! !

!Temperature class methodsFor: 'position' stamp: 'NM 12/30/2021 05:00:22'!
zone1
	". Return a decimal value in Celsius degree  
	. the temperature of this area must not surpass 85C or the BB-AI will shut down " 
	^ '/sys/devices/virtual/thermal/thermal_zone1/temp' asFileEntry fileContents asNumber  / 1000.0 . ! !

!BBExamples methodsFor: 'examples' stamp: 'NM 12/5/2021 17:43:30'!
exGpioOut1
	".  Copy these lines in the Workspace and run them by hand one by one checking the results.
	. set a pin as output pin, default 'off', implied pullDown resistor parameter "
	|go1|
	go1 _ GpioOut newAtHeader: 9 position: 11 pull: #down.
	" . read the pin status "
	go1 status. 
	". toggle the pin value, "
	go1 on. 
	go1 off. 
	go1 on.
	go1 off. ! !
