'''
                                        Radix 2 FFT Butterfly Unit        

Description :           This code is designed to implement radix 4 FFT Butterfly Unit. 
                It calculates the appropriate output according to input samples values and twiddle factor value.

Date: 05/2023
Author : Mohamed Sharaf
'''

from math import *
def butterfly_unit (input_0,input_1,twiddle):

    result = []
    x_0 = input_0 + input_1
    result.append(x_0)

    x_1 = (input_0 - input_1)*twiddle
    result.append(x_1)

    return result



