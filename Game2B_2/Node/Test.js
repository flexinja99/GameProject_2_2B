const {add} = require("./Math.js");

let num = 42;                //int
var name = "TOM";             //string
let isStudent = true;         //bool

//배열
let color = ["red" , "green" , "blue"];
//객체
let person = {name : "Alice " , age : 30};

console.log(add(num,num));


//함수
function greet(name)
{
    console.log("Hello" + name + " ! ");
}
//함수 호출
greet(person.name);

//조건문
if(num > 30)
{
    console.log("Number is greater than 30");
}
else
{
    console.log("Number is lower than 30");
}

//반복문
for(var i = 0 ; i < 5; i++)
{
    console.log(i);
}

setTimeout(() => {
    console.log("Delayed message1");
}, 1000);

setTimeout(() => {
    console.log("Delayed message2");
}, 750);

setTimeout(() => {
    console.log("Delayed message3");
}, 2000);

setTimeout(() => {
    console.log("Delayed message4");
}, 500);
