// automatically generated, do not modify

namespace keron.server
{

using FlatBuffers;

public class Configuration : Table {
  public static Configuration GetRootAsConfiguration(ByteBuffer _bb) { return GetRootAsConfiguration(_bb, new Configuration()); }
  public static Configuration GetRootAsConfiguration(ByteBuffer _bb, Configuration obj) { return (obj.__init(_bb.GetInt(_bb.position()) + _bb.position(), _bb)); }
  public Configuration __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public string Address() { int o = __offset(4); return o != 0 ? __string(o + bb_pos) : null; }
  public ushort Port() { int o = __offset(6); return o != 0 ? bb.GetUshort(o + bb_pos) : (ushort)0; }
  public uint Maxclients() { int o = __offset(8); return o != 0 ? bb.GetUint(o + bb_pos) : (uint)0; }

  public static int CreateConfiguration(FlatBufferBuilder builder,
      int address = 0,
      ushort port = 0,
      uint maxclients = 0) {
    builder.StartObject(3);
    Configuration.AddMaxclients(builder, maxclients);
    Configuration.AddAddress(builder, address);
    Configuration.AddPort(builder, port);
    return Configuration.EndConfiguration(builder);
  }

  public static void StartConfiguration(FlatBufferBuilder builder) { builder.StartObject(3); }
  public static void AddAddress(FlatBufferBuilder builder, int addressOffset) { builder.AddOffset(0, addressOffset, 0); }
  public static void AddPort(FlatBufferBuilder builder, ushort port) { builder.AddUshort(1, port, 0); }
  public static void AddMaxclients(FlatBufferBuilder builder, uint maxclients) { builder.AddUint(2, maxclients, 0); }
  public static int EndConfiguration(FlatBufferBuilder builder) {
    int o = builder.EndObject();
    return o;
  }
  public static void FinishConfigurationBuffer(FlatBufferBuilder builder, int offset) { builder.Finish(offset); }
};


}
