// automatically generated, do not modify

namespace keron.messages
{

using FlatBuffers;

public class Chat : Table {
  public static Chat GetRootAsChat(ByteBuffer _bb) { return GetRootAsChat(_bb, new Chat()); }
  public static Chat GetRootAsChat(ByteBuffer _bb, Chat obj) { return (obj.__init(_bb.GetInt(_bb.position()) + _bb.position(), _bb)); }
  public Chat __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public string From() { int o = __offset(4); return o != 0 ? __string(o + bb_pos) : null; }
  public string Message() { int o = __offset(6); return o != 0 ? __string(o + bb_pos) : null; }

  public static int CreateChat(FlatBufferBuilder builder,
      int from = 0,
      int message = 0) {
    builder.StartObject(2);
    Chat.AddMessage(builder, message);
    Chat.AddFrom(builder, from);
    return Chat.EndChat(builder);
  }

  public static void StartChat(FlatBufferBuilder builder) { builder.StartObject(2); }
  public static void AddFrom(FlatBufferBuilder builder, int fromOffset) { builder.AddOffset(0, fromOffset, 0); }
  public static void AddMessage(FlatBufferBuilder builder, int messageOffset) { builder.AddOffset(1, messageOffset, 0); }
  public static int EndChat(FlatBufferBuilder builder) {
    int o = builder.EndObject();
    return o;
  }
};


}
