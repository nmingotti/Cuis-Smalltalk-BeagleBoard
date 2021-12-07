Prova 

#     Cuis-Smalltalk-BeagleBoard
A package to control BeagleBone pins in Smalltalk 

##    Objectives, Plan & Status
This package is started 27-Nov-2021 with zero existing code. The long term plan is to implement this:
*     Controle on board leds 
*     Control GPIO input and output
*     Control PWM 
*     Control A/D converter
*     Interrupts
*     I2C
*     UART 
* (difficult) Interface to the 2 separate computation units for real time processing
* (fun) Make morphs to control graphicall the pin statuses
* **Memo for me**. At the beginning offload all what is possible to shell commands. This will be extremely inefficient but permit me to try the programmer interface with the least effort.

## Simplest test applications
* on bard leds : "Knight rider Kit effet"
* GPIO out : a single led
* GPIO input : read status of a switch or push button
* PWM : change a led light intensity
* AD : read angle of of a potentiometer

## More advanced application 
* Control stepper motor
* Control servo motor
* Audio output 
* Audio input 

## Hardware 
In principle the code should work in any **BeagleBone Black**. But I will develop and test 
all in a **BeagleBone AI** because it seems powerfull enough to permit a smooth enough
developement cycle. 

## Testing 

* Testing will require a circuit attached to the board and a human checking the output
* **Memo for me**. Try to implement the test circuits in such a way that they are as much as possible independent but they go forming part of a larger circuit that contains all them. This way it will be necessary to have only one breadboard and not to redo the wiring every time we want to test a new feature.

### Testing GPIO out 
* First exaple. Turn on and off a digital output pin. As an application turn on and off a led.  
<img src="https://github.com/nmingotti/Cuis-Smalltalk-BeagleBoard/blob/main/docs/img/circuit-gpio-out-2.jpg" width="50%" alt="gpio-out-1">



