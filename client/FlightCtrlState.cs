// automatically generated, do not modify

namespace keron
{

using FlatBuffers;

public class FlightCtrlState : Table {
  public static FlightCtrlState GetRootAsFlightCtrlState(ByteBuffer _bb) { return GetRootAsFlightCtrlState(_bb, new FlightCtrlState()); }
  public static FlightCtrlState GetRootAsFlightCtrlState(ByteBuffer _bb, FlightCtrlState obj) { return (obj.__init(_bb.GetInt(_bb.position()) + _bb.position(), _bb)); }
  public FlightCtrlState __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public float FastThrottle() { int o = __offset(4); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }
  public sbyte Toggles() { int o = __offset(6); return o != 0 ? bb.GetSbyte(o + bb_pos) : (sbyte)0; }
  public float MainThrottle() { int o = __offset(8); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }
  public float Pitch() { int o = __offset(10); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }
  public float PitchTrim() { int o = __offset(12); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }
  public float Roll() { int o = __offset(14); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }
  public float RollTrim() { int o = __offset(16); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }
  public float X() { int o = __offset(18); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }
  public float Y() { int o = __offset(20); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }
  public float Yaw() { int o = __offset(22); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }
  public float YawTrim() { int o = __offset(24); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }
  public float Z() { int o = __offset(26); return o != 0 ? bb.GetFloat(o + bb_pos) : (float)0; }

  public static int CreateFlightCtrlState(FlatBufferBuilder builder,
      float fastThrottle = 0,
      sbyte toggles = 0,
      float mainThrottle = 0,
      float pitch = 0,
      float pitchTrim = 0,
      float roll = 0,
      float rollTrim = 0,
      float X = 0,
      float Y = 0,
      float yaw = 0,
      float yawTrim = 0,
      float Z = 0) {
    builder.StartObject(12);
    FlightCtrlState.AddZ(builder, Z);
    FlightCtrlState.AddYawTrim(builder, yawTrim);
    FlightCtrlState.AddYaw(builder, yaw);
    FlightCtrlState.AddY(builder, Y);
    FlightCtrlState.AddX(builder, X);
    FlightCtrlState.AddRollTrim(builder, rollTrim);
    FlightCtrlState.AddRoll(builder, roll);
    FlightCtrlState.AddPitchTrim(builder, pitchTrim);
    FlightCtrlState.AddPitch(builder, pitch);
    FlightCtrlState.AddMainThrottle(builder, mainThrottle);
    FlightCtrlState.AddFastThrottle(builder, fastThrottle);
    FlightCtrlState.AddToggles(builder, toggles);
    return FlightCtrlState.EndFlightCtrlState(builder);
  }

  public static void StartFlightCtrlState(FlatBufferBuilder builder) { builder.StartObject(12); }
  public static void AddFastThrottle(FlatBufferBuilder builder, float fastThrottle) { builder.AddFloat(0, fastThrottle, 0); }
  public static void AddToggles(FlatBufferBuilder builder, sbyte toggles) { builder.AddSbyte(1, toggles, 0); }
  public static void AddMainThrottle(FlatBufferBuilder builder, float mainThrottle) { builder.AddFloat(2, mainThrottle, 0); }
  public static void AddPitch(FlatBufferBuilder builder, float pitch) { builder.AddFloat(3, pitch, 0); }
  public static void AddPitchTrim(FlatBufferBuilder builder, float pitchTrim) { builder.AddFloat(4, pitchTrim, 0); }
  public static void AddRoll(FlatBufferBuilder builder, float roll) { builder.AddFloat(5, roll, 0); }
  public static void AddRollTrim(FlatBufferBuilder builder, float rollTrim) { builder.AddFloat(6, rollTrim, 0); }
  public static void AddX(FlatBufferBuilder builder, float X) { builder.AddFloat(7, X, 0); }
  public static void AddY(FlatBufferBuilder builder, float Y) { builder.AddFloat(8, Y, 0); }
  public static void AddYaw(FlatBufferBuilder builder, float yaw) { builder.AddFloat(9, yaw, 0); }
  public static void AddYawTrim(FlatBufferBuilder builder, float yawTrim) { builder.AddFloat(10, yawTrim, 0); }
  public static void AddZ(FlatBufferBuilder builder, float Z) { builder.AddFloat(11, Z, 0); }
  public static int EndFlightCtrlState(FlatBufferBuilder builder) {
    int o = builder.EndObject();
    return o;
  }
};


}
