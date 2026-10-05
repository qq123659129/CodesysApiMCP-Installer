(* 已提交但未通过编译及最终读回，仅用于保留本次代码。不要视作已保存工程。 *)
(* 复核说明：下方 fbPID 是官方 Util 3.5.19.0 的 PID_FIXCYCLE 实例；fbPID(...) 即实际调用。 *)
(* 本文件是原提交代码的留存稿，本轮只补充定位注释；没有重新写入或保存到 CODESYS 工程。 *)
FUNCTION_BLOCK FB_TemperatureControl
VAR_INPUT
    rTarget_C : REAL := 60.0; // 目标温度，测试允许范围为 0 至 150 摄氏度
    rFeedback_C : REAL := 20.0; // 反馈温度，测试有效范围为 -50 至 200 摄氏度
    xEnable : BOOL := FALSE; // 使能加热控制；关闭时输出为零并复位积分
    xReset : BOOL := FALSE; // 复位期间输出为零，输入恢复正常后可清除锁存故障
    xSensorFault : BOOL := FALSE; // 外部反馈故障标记；本测试不连接实体传感器
END_VAR
VAR_OUTPUT
    rOutput_pct : REAL := 0.0; // 加热输出百分比，始终限制在 0 至 100
    xFault : BOOL := FALSE; // 输入异常或控制器溢出时锁存，需有效输入及复位才能清除
    xLimited : BOOL := FALSE; // 官方控制器当前是否处于输出限幅
END_VAR
VAR
    fbPID : Util.PID_FIXCYCLE; // 官方 Util 库固定周期 PID 功能块实例，在下方 fbPID(...) 调用
    xInputValid : BOOL; // 温度范围和反馈状态有效性
    xSafeReset : BOOL; // 停用、复位、故障或首次调用时复位控制器
    xInitialized : BOOL := FALSE; // 首次调用先复位，避免沿用不明确的积分初值
    rActualSafe_C : REAL; // 传给官方控制器的有效反馈，异常时使用零
    rTargetSafe_C : REAL; // 传给官方控制器的有效目标，异常时使用零
END_VAR
VAR CONSTANT
    rCycle_s : REAL := 0.01; // 固定周期为 10ms，必须与 MainTask 一致
    rKp : REAL := 2.0; // 比例增益，测试初值为每摄氏度 2% 输出
    rTn_s : REAL := 20.0; // 积分时间为 20 秒，仅为模拟对象提供测试初值
    rTv_s : REAL := 0.5; // 微分时间为 0.5 秒，未对实体设备整定
END_VAR
// 先确认输入处于测试有效范围；范围判断也阻止非正常数值进入控制器。
xInputValid := NOT xSensorFault
    AND (rTarget_C >= 0.0) AND (rTarget_C <= 150.0)
    AND (rFeedback_C >= -50.0) AND (rFeedback_C <= 200.0);

// 故障保持锁存；只有反馈恢复有效且明确复位时才清除。
IF NOT xInputValid THEN
    xFault := TRUE;
ELSIF xReset THEN
    xFault := FALSE;
END_IF;

rActualSafe_C := 0.0;
rTargetSafe_C := 0.0;
IF xInputValid THEN
    rActualSafe_C := rFeedback_C;
    rTargetSafe_C := rTarget_C;
END_IF;

xSafeReset := NOT xEnable OR xReset OR xFault OR NOT xInitialized;

// 官方 PID 功能块的实际调用入口：CYCLE 为 0.01 秒，与要求的 10ms 任务一致。
// 每个周期只执行一次；停用和故障时复位积分并保持零输出。
fbPID(
    ACTUAL := rActualSafe_C,
    SET_POINT := rTargetSafe_C,
    KP := rKp,
    TN := rTn_s,
    TV := rTv_s,
    Y_MANUAL := 0.0,
    Y_OFFSET := 0.0,
    Y_MIN := 0.0,
    Y_MAX := 100.0,
    MANUAL := xSafeReset,
    RESET := xSafeReset,
    CYCLE := rCycle_s
);
xInitialized := TRUE;

// 当周期发现溢出或异常输出立即停热；下周期继续复位官方控制器。
IF fbPID.OVERFLOW OR NOT ((fbPID.Y >= 0.0) AND (fbPID.Y <= 100.0)) THEN
    xFault := TRUE;
END_IF;

rOutput_pct := 0.0;
xLimited := FALSE;
IF xEnable AND NOT xReset AND NOT xSafeReset AND NOT xFault THEN
    rOutput_pct := LIMIT(0.0, fbPID.Y, 100.0);
    xLimited := fbPID.LIMITS_ACTIVE;
END_IF;
