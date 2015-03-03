// automatically generated, do not modify

namespace keron.messages
{

using FlatBuffers;

public class FlightCtrl : Table {
  public static FlightCtrl GetRootAsFlightCtrl(ByteBuffer _bb) { return GetRootAsFlightCtrl(_bb, new FlightCtrl()); }
  public static FlightCtrl GetRootAsFlightCtrl(ByteBuffer _bb, FlightCtrl obj) { return (obj.__init(_bb.GetInt(_bb.position()) + _bb.position(), _bb)); }
  public FlightCtrl __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public FlightCtrlState State() { return State(new FlightCtrlState()); }
  public FlightCtrlState State(FlightCtrlState obj) { int o = __offset(4); return o != 0 ? obj.__init(__indirect(o + bb_pos), bb) : null; }

  public static int CreateFlightCtrl(FlatBufferBuilder builder,
      int state = 0) {
    builder.StartObject(1);
    FlightCtrl.AddState(builder, state);
    return FlightCtrl.EndFlightCtrl(builder);
  }

  public static void StartFlightCtrl(FlatBufferBuilder builder) { builder.StartObject(1); }
  public static void AddState(FlatBufferBuilder builder, int stateOffset) { builder.AddOffset(0, stateOffset, 0); }
  public static int EndFlightCtrl(FlatBufferBuilder builder) {
    int o = builder.EndObject();
    return o;
  }
};


}
