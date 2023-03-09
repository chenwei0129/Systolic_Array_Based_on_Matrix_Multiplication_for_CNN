# Systolic Array Based on Matrix Multiplication for CNN

## *We use systolic array to implement matrix multilication to execute CNN.*
## The architecture is shown below, and each block is a PE. It can apply W*X matrix multiplication, W means weight, X means input feature map, and there size are 4×16, 16×N，respectivelly. N is an arbitrary number.
### PS : The weight and input feature map need to be transfer to matrix by image to column.

![image](https://user-images.githubusercontent.com/125378013/223890178-faa3c05a-cdfd-431f-ab89-0392e0598f99.png)

## The data type of W and X is {1, 5, 8}, which represent 1 signed bit, 5bits integer, and 8bits floating point.
## The following are the network architecture and the size of matrix.

![image](https://user-images.githubusercontent.com/125378013/223891271-63ea338e-9065-4d74-bcb9-fabc0ed0be7a.png)

## There is the system including systolic array, controller, and the testbench.
### Convolution and fully connected layer are executed in hardware, and maxpooling and im2col are done in software.

![image](https://user-images.githubusercontent.com/125378013/223891568-938c1da8-1344-4a00-aed0-cae9bdb7c2b4.png)

## Finally, the APR is finish, there are some data and layout.

![area](https://user-images.githubusercontent.com/125378013/223779262-7f7f3f0d-5d0a-4131-a5cd-0003eab1ccd9.png)


![layout](https://user-images.githubusercontent.com/125378013/223779232-82eea859-c85e-456f-b50c-3492dfacc4d7.png)

