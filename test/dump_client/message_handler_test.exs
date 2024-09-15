defmodule DumpClient.MessageHandlerTest do
  use ExUnit.Case

  # test "handle_message aircraft identification" do
  #   decoded_msg = DumpClient.MessageHandler.decode_frame("*8D4840D6202CC371C32CE0576098;")
  #
  #   assert decoded_msg.message.category == "No category information"
  #   assert decoded_msg.message.callsign == "KLM1023 "
  # end
  #
  # test "handle_message airborne velocity with ground speed subtype" do
  #   # Message is sub-type 1 for subsonic aircraft
  #   decoded_msg =
  #     DumpClient.MessageHandler.decode_frame("*8D485020994409940838175B284F;")
  #
  #   assert decoded_msg.downlink_format == 17
  #   assert decoded_msg.icao == "485020"
  #
  #   assert decoded_msg.message.type_code == 19
  #   assert decoded_msg.message.sub_type == 1
  #   assert decoded_msg.message.vertical_rate_src == "GNSS"
  #   assert decoded_msg.message.vertical_rate == -832
  #   assert decoded_msg.message.gnss_baro_diff == 550
  #
  #   assert decoded_msg.message.sub_type_message.ground_speed == 159.20
  #   assert decoded_msg.message.sub_type_message.ground_track_angle == 182.88
  # end
  #
  # test "handle_message airborne velocity with airspeed subtype" do
  #   # Message is sub-type 3 for subsonic aircraft
  #   decoded_msg = DumpClient.MessageHandler.decode_frame("*8DA05F219B06B6AF189400CBC33F;")
  #
  #   assert decoded_msg.downlink_format == 17
  #   assert decoded_msg.icao == "A05F21"
  #
  #   assert decoded_msg.message.type_code == 19
  #   assert decoded_msg.message.sub_type == 3
  #   assert decoded_msg.message.vertical_rate_src == "Barometer"
  #   assert decoded_msg.message.vertical_rate == -2304
  #
  #   # TODO 0 has two meanings, either the difference is actually 0 or the information is not available
  #   assert decoded_msg.message.gnss_baro_diff == 0
  #
  #   assert decoded_msg.message.sub_type_message.magnetic_heading == 243.98
  #   assert decoded_msg.message.sub_type_message.airspeed == 375
  #   assert decoded_msg.message.sub_type_message.airspeed_type == "True"
  # end
end

# ADSB Sample
# ==============================

# *020012800CDD8E;
# *8DA260939910CA01D84803AF4C3A;
# *8DA0E2E89914CE01C8600E68F0DA;
# *8DC07C7A581D66F0418785AEFFAD;
# *8DC07C7A9988029EA84C0561689A;
# *8DA8A0C1583DB722F7878EF2A5C9;
# *02A183B34C264D;
# *8DABB93099102E1D984406A143E7;
# *02059680F77EEF;
# *8DABB930581F36F0FD7F3805B353;
# *8DA8A0C1F8230002004AB8C110DB;
# *02818336F84938;
# *02818336F84938;
# *0200168034EB8E;
# *8DA26093EA07E840015F08A2462E;
# *8DABB93099102D1DB84806A97A9C;
# *8DABB930581F23775AD142F7C78A;
# *2000079C05485C;
# *0281833507A12A;
# *20000335CEFD1B;
# *280005AD4D58FE;
# *5DA260936AF505;
# *8DA0E2E89914CE0128640D8AAE1E;
# *02059680F77EEF;
# *8DA8A0C1583DC722AF8793A7A1A8;
# *8DABB930581F26F12B7F3C8F9BBF;
# *5DABB930EB8D98;
# *8DA0E2E858B406DCD5938BA3B587;
# *8DA0E2E89914CE00E8600DF999B2;
# *02A1839526069A;
# *8DA8A0C199902BA5F08416F461B5;
# *5DA8A0C199181A;
# *02A183B2B3D244;
# *02A1839526069A;
# *02A183B14C3A56;
# *8DABB930EA04C844035C08D3DBA8;
# *8DABB93099102B1DF85006B9086A;
# *8DABB930F8230006004AB81F4B53;
# *8DABB930581F137788D146001AF1;
# *8DA0E2E89914CE00A8600C8C95E9;
# *02A18394D9F293;
# *02A183B14C3A56;
# *8DC07C7A581D46EFE18785ACFBEA;
# *5DABB930EB8D98;
# *02C1879DB91836;
# *8DA260939910C902384803F3D44B;
# *02A6039401CF70;
# *8DABB93099102B1DF84C07EE7E63;
# *5DC07C7AEC9B89;
# *8DA26093234CB5F3E38DE0A68BFF;
# *02A183B14C3A56;
# *02A183B14C3A56;
# *02A18394D9F293;
# *8DC07C7A581D46EFCD8785B074CF;
# *8DA8A0C1EA447840015F889F4770;
# *02A183B14C3A56;
# *8DA8A0C199902BA5F0881743CFBC;
# *02A183B14C3A56;
# *8DABB930581F1377B2D14AED6018;
# *8DC07C7AEA07E845D15C086A2686;
# *8DABB9309910281E184C064D121B;
# *5DA260936AF505;
# *8DABB930E102BC00000000983D84;
# *20000393AA02AF;
# *20000393AA02AF;
# *8DA26093EA07E840015F08A2462E;
# *8DABB9309910281E184C064D121B;
# *2800139B8268E9;
# *02A183B0B3CE5F;
# *8DC07C7A9988029E685005A91665;
# *8DA26093F8230002004AB8E6AF28;
# *02818333078507;
