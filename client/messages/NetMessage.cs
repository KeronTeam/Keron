// automatically generated, do not modify

namespace keron.messages
{

using FlatBuffers;

public class NetMessage : Table {
  public static NetMessage GetRootAsNetMessage(ByteBuffer _bb) { return GetRootAsNetMessage(_bb, new NetMessage()); }
  public static NetMessage GetRootAsNetMessage(ByteBuffer _bb, NetMessage obj) { return (obj.__init(_bb.GetInt(_bb.position()) + _bb.position(), _bb)); }
  public NetMessage __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public byte MessageType() { int o = __offset(4); return o != 0 ? bb.Get(o + bb_pos) : (byte)0; }
  public Table Message(Table obj) { int o = __offset(6); return o != 0 ? __union(obj, o) : null; }

  public static int CreateNetMessage(FlatBufferBuilder builder,
      byte message_type = 0,
      int message = 0) {
    builder.StartObject(2);
    NetMessage.AddMessage(builder, message);
    NetMessage.AddMessageType(builder, message_type);
    return NetMessage.EndNetMessage(builder);
  }

  public static void StartNetMessage(FlatBufferBuilder builder) { builder.StartObject(2); }
  public static void AddMessageType(FlatBufferBuilder builder, byte messageType) { builder.AddByte(0, messageType, 0); }
  public static void AddMessage(FlatBufferBuilder builder, int messageOffset) { builder.AddOffset(1, messageOffset, 0); }
  public static int EndNetMessage(FlatBufferBuilder builder) {
    int o = builder.EndObject();
    return o;
  }
  public static void FinishNetMessageBuffer(FlatBufferBuilder builder, int offset) { builder.Finish(offset); }
};


}
