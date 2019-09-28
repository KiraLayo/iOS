import Foundation

let max = 1<<9 - 1;

let min = 1<<9 * -1;


func reverse(_ x: Int) -> Int {
    let bit = 32-1;
    Int.max
    Int32.max
    let max = 1<<bit - 1;
    let maxLast = max%10;
    let min = 1<<bit * -1;
    let minLast = min%10;

    var input = x;
    var output:Int = 0;
    while(input != 0){
        let last = input % 10;
        input /= 10;

        if ((output == max/10) && (last > maxLast)) || (output > max/10) {
            return 0;
        }

        if ((output == min/10) && (last < minLast)) || (output < min/10) {
            return 0;
        }

        output = output * 10 + last;
    }

    return output;
}

let res = reverse(-120)


