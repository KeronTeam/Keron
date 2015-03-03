// automatically generated, do not modify

namespace keron.messages
{

using FlatBuffers;

public class Message : Table {
  public static Message GetRootAsMessage(ByteBuffer _bb) { return GetRootAsMessage(_bb, new Message()); }
  public static Message GetRootAsMessage(ByteBuffer _bb, Message obj) { return (obj.__init(_bb.GetInt(_bb.position()) + _bb.position(), _bb)); }
  public Message __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public byte MessageType() { int o = __offset(4); return o != 0 ? bb.Get(o + bb_pos) : (byte)0; }
  public Table MessageConst(Table obj) { int o = __offset(6); return o != 0 ? __union(obj, o) : null; }

  public static int CreateMessage(FlatBufferBuilder builder,
      byte message_type = 0,
      int message = 0) {
    builder.StartObject(2);
    Message.AddMessage(builder, message);
    Message.AddMessageType(builder, message_type);
    return Message.EndMessage(builder);
  }

  public static void StartMessage(FlatBufferBuilder builder) { builder.StartObject(2); }
  public static void AddMessageType(FlatBufferBuilder builder, byte messageType) { builder.AddByte(0, messageType, 0); }
  public static void AddMessage(FlatBufferBuilder builder, int messageOffset) { builder.AddOffset(1, messageOffset, 0); }
  public static int EndMessage(FlatBufferBuilder builder) {
    int o = builder.EndObject();
    return o;
  }
  public static void FinishMessageBuffer(FlatBufferBuilder builder, int offset) { builder.Finish(offset); }
};


}
