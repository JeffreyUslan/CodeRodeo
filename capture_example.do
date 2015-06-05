*BAAAAD, but effective
capture gen mpg=784
	if _rc {
		replace mpg=784
	}
*GOOD
capture confirm variable mpg
if _rc {
  generate mpg = 784
}
else {
  replace mpg = 784
}


capture {


! copy data.txt data2.txt










}
