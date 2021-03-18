const ffi = require('ffi-napi');

function startSession(agentId,svcToken,clientId){
    tools = ffi.Library('dll/answertools.dll', {
        'StartSession': ['string', ['string','string','string']]
    });
    var result=tools.StartSession(agentId,svcToken,clientId);
    return result;
}

function startQuestion(queTypeStr,texts,flashCount,config){
    tools = ffi.Library('dll/answertools.dll', {
        'StartQuestion': ['string', ['string','string','string','string']]
    });
    var result=tools.StartQuestion(queTypeStr,texts,flashCount,config);
    return result;
}

function endQuestion(finishTexts){
    tools = ffi.Library('dll/answertools.dll', {
        'EndQuestion': ['string', ['string']]
    });
    var result=tools.EndQuestion(finishTexts);
    return result;
}

function getAnswers(){
    tools = ffi.Library('dll/answertools.dll', {
        'GetAnswers': ['string', []]
    });
    var result=tools.GetAnswers();
    return result;
}





function initTools(){
    tools = ffi.Library('dll/answertools.dll', {
        'initTools': ['void', []]
    });
    tools.initTools();
}

function testDLL(text){
  console.log("favor: " + process.env.FAVOR);
  tools = ffi.Library('dll/answertools.dll', {
        'test': ['string', ['string']]
    });
  var result= tools.test(text);
  return result;
}

function testDeviceConnection(){
  tools = ffi.Library('dll/answertools.dll', {
        'testDeviceConnection': ['void', []]
    });
  tools.testDeviceConnection();
}

function getConnectedDevices(){
  tools = ffi.Library('dll/answertools.dll', {
        'GetConnectedDevices': ['string', []]
    });
  var result= tools.GetConnectedDevices();
  return result;
}

function toBinaryString(text) {
  return new Buffer(text, 'ucs2').toString('binary');
}



function test(){
/**
 * 先定义一个函数, 用来在窗口中显示字符
 * @param {String} text
 * @return {*} none
 */
function showText(text) {
  return new Buffer(text, 'ucs2').toString('binary');
};
// 通过ffi加载user32.dll
const myUser32 = new ffi.Library('user32', {
  'MessageBoxW': // 声明这个dll中的一个函数
    [
      'int32', ['int32', 'string', 'string', 'int32'], // 用json的格式罗列其返回类型和参数类型
    ],
});

// 调用user32.dll中的MessageBoxW()函数, 弹出一个对话框
const isOk = myUser32.MessageBoxW(
    0, showText('I am Node.JS!'), showText('Hello, World!'), 1
);
console.log(isOk);
}

function showJSDialog(text) {
    alert('dll caller alert '+text)
    return 'success!';
}

function hello(){
return 'world';
}

