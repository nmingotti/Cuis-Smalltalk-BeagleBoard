'From Cuis 5.0 [latest update: #4885] on 5 December 2021 at 6:00:46 pm'!
'Description '!
!provides: 'BeagleBoard' 1 11!
!requires: 'Cuis-Base' 50 4885 nil!
!requires: 'CommandShell' 1 2 nil!
!requires: 'Regex' 1 5 nil!
!requires: 'OSProcess' 1 17 nil!
SystemOrganization addCategory: 'BeagleBoard-Examples'!
SystemOrganization addCategory: 'BeagleBoard'!


!classDefinition: #BBExamples category: 'BeagleBoard-Examples'!
Object subclass: #BBExamples
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard-Examples'!
!classDefinition: 'BBExamples class' category: 'BeagleBoard-Examples'!
BBExamples class
	instanceVariableNames: ''!

!classDefinition: #Pin category: 'BeagleBoard'!
Object subclass: #Pin
	instanceVariableNames: 'header position'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard'!
!classDefinition: 'Pin class' category: 'BeagleBoard'!
Pin class
	instanceVariableNames: ''!

!classDefinition: #Gpio category: 'BeagleBoard'!
Pin subclass: #Gpio
	instanceVariableNames: 'sysfsDirectory'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard'!
!classDefinition: 'Gpio class' category: 'BeagleBoard'!
Gpio class
	instanceVariableNames: ''!

!classDefinition: #GpioOut category: 'BeagleBoard'!
Gpio subclass: #GpioOut
	instanceVariableNames: 'pull status'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BeagleBoard'!
!classDefinition: 'GpioOut class' category: 'BeagleBoard'!
GpioOut class
	instanceVariableNames: ''!


!Pin commentStamp: '<historical>' prior: 0!
I am a physical pin into on the BeagleBoard. I can't do much, my subblasses to all the work.
=== iVars ======
. header : String 
. position : String 
=============
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

!Pin methodsFor: 'as yet unclassified' stamp: 'NM 12/5/2021 15:37:23'!
name
	". Return the pin name, e.g. P9_11. It means header 9 and position 11 over that header . 
	. This is the standard way of naming pings in the BeagleBoard. There exists other format as  'P9.11', 'p9_11' etc. "
	^ 'P{1}_{2}' format: {header. position.}.! !

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
