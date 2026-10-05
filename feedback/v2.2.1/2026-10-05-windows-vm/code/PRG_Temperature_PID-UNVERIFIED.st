(* 已提交但未通过编译及最终读回，仅用于保留本次代码。不要视作已保存工程。 *)
(* 官方 PID 调用路径：本程序 fbTemperature(...) → FB_TemperatureControl 内的 fbPID : Util.PID_FIXCYCLE。 *)
(* 本轮只补充定位注释；官方 PID 的完整参数调用请查看同目录 FB_TemperatureControl.st。 *)
PROGRAM PRG_Temperature_PID
VAR
    rTarget_C : REAL := 60.0; // 目标温度，Trace 的第一条温度曲线
    rFeedback_C : REAL := 20.0; // 反馈温度，默认来自下方测试模拟对象
    rOutput_pct : REAL := 0.0; // 输出百分比，Trace 单独显示 0 至 100
    xEnable : BOOL := TRUE; // 测试控制使能，关闭后加热输出为零
    xReset : BOOL := FALSE; // 人工复位测试开关，保持期间输出为零
    xSensorFault : BOOL := FALSE; // 测试用故障注入，不对应实体输入
    xSimulate : BOOL := TRUE; // 明确为测试模拟；关闭后可人工设置反馈变量
    xFault : BOOL := FALSE; // 温控模块锁存的故障状态
    xLimited : BOOL := FALSE; // 温控输出限幅状态
    fbTemperature : FB_TemperatureControl; // 本程序内唯一的温控实例
    rSimTemperature_C : REAL := 20.0; // 一阶测试温度对象的跨周期状态
END_VAR
VAR CONSTANT
    rCycle_s : REAL := 0.01; // MainTask 固定 10ms，模拟步长与控制周期一致
    rAmbient_C : REAL := 20.0; // 测试模拟环境温度为 20 摄氏度
    rPlantTau_s : REAL := 20.0; // 测试模拟时间常数为 20 秒
    rPlantGain_C_per_pct : REAL := 1.0; // 测试模型中每 1% 输出使稳态温度升高 1 摄氏度
END_VAR
// 仅测试模拟：一阶加热对象使用上一周期输出，所有变量都未映射实体 I/O。
IF xReset THEN
    rSimTemperature_C := rAmbient_C;
ELSIF xSimulate THEN
    rSimTemperature_C := rSimTemperature_C + rCycle_s / rPlantTau_s
        * (rAmbient_C + rPlantGain_C_per_pct * rOutput_pct - rSimTemperature_C);
END_IF;

IF xSimulate THEN
    rFeedback_C := rSimTemperature_C;
END_IF;

// MainTask 每 10ms 只调用本程序一次，本程序也只调用温控实例一次。
fbTemperature(
    rTarget_C := rTarget_C,
    rFeedback_C := rFeedback_C,
    xEnable := xEnable,
    xReset := xReset,
    xSensorFault := xSensorFault
);
rOutput_pct := fbTemperature.rOutput_pct;
xFault := fbTemperature.xFault;
xLimited := fbTemperature.xLimited;
