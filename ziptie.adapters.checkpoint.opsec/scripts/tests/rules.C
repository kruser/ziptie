(
        :auth (
                : (rule-3
                        :AdminInfo (
                                :chkpf_uid ("{434BA892-C6D4-41D3-B10F-CCD3DCC5624A}")
                                :ClassName (security_rule)
                        )
                        :action (
                                : ("Client Encrypt"
                                        :type (userc)
                                        :macro (USER_CLIENT_ENCRYPT)
                                        :src_options ("Intersect with User Database")
                                        :dst_options ("Intersect with User Database")
                                        :action (accept)
                                        :enforce_desktop_config (true)
                                )
                        )
                        :disabled (false)
                        :global_location (middle)
                        :through (
                                : (ReferenceObject
                                        :Name (Any)
                                )
                        )
                        :time (
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :track (
                                : Log
                        )
                        :dst (
                                :AdminInfo (
                                        :chkpf_uid ("{E438E443-EEC1-490C-B768-871DDBBEEC71}")
                                        :ClassName (rule_destination)
                                )
                                :compound ()
                                :op ()
                                : net-oslo
                        )
                        :install (
                                :AdminInfo (
                                        :chkpf_uid ("{521B34F2-FE75-417A-92C3-7DADBAE2C0E6}")
                                        :ClassName (rule_install)
                                )
                                :compound ()
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :services (
                                :AdminInfo (
                                        :chkpf_uid ("{F7E3BAFA-CEFC-4FF2-AA8A-129F284CB852}")
                                        :ClassName (rule_services)
                                )
                                :compound ()
                                :op ()
                                : http
                                : ftp
                        )
                        :src (
                                :AdminInfo (
                                        :chkpf_uid ("{CB88EB10-D2B0-4DB5-8BBE-B5049130DDF9}")
                                        :ClassName (rule_source)
                                )
                                :compound (
                                        : (SC_Users@Any
                                                :AdminInfo (
                                                        :chkpf_uid ("{C2CB4115-1CB9-4807-ACAD-FA29E7995FD9}")
                                                        :ClassName (rule_user_group)
                                                )
                                                :at (Any
                                                        :color (Blue)
                                                )
                                                :color (darkorange3)
                                                :type (usrgroup)
                                        )
                                )
                                :op ()
                        )
                )
        )
        :crypt ()
        :logic ()
        :proxy ()
        :rules (
                : (rule-1
                        :AdminInfo (
                                :chkpf_uid ("{1BDF9036-2FC0-43C6-85C6-24E7B6C1370D}")
                                :ClassName (security_rule)
                        )
                        :action (
                                : (accept
                                        :AdminInfo (
                                                :chkpf_uid ("{8F308ECD-CCBD-4203-A0B1-51F5DFF51FD9}")
                                                :ClassName (accept_action)
                                                :table (setup)
                                        )
                                        :action ()
                                        :macro (RECORD_CONN)
                                        :type (accept)
                                )
                        )
                        :disabled (false)
                        :global_location (middle)
                        :through (
                                : (ReferenceObject
                                        :Name (Any)
                                        :Table (globals)
                                        :Uid ("{97AEB369-9AEA-11D5-BD16-0090272CCB30}")
                                )
                        )
                        :time (
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :track (
                                : None
                        )
                        :dst (
                                :AdminInfo (
                                        :chkpf_uid ("{E92C9419-DB73-4DD1-B107-61F4AEB8F638}")
                                        :ClassName (rule_destination)
                                )
                                :compound ()
                                :op ()
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :install (
                                :AdminInfo (
                                        :chkpf_uid ("{DC22E9BB-607A-4825-BAF9-D7AD25E900B6}")
                                        :ClassName (rule_install)
                                )
                                :compound ()
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :services (
                                :AdminInfo (
                                        :chkpf_uid ("{9709715D-D54F-4181-A39C-C4D0D695FAEF}")
                                        :ClassName (rule_services)
                                )
                                :compound ()
                                :op ()
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :src (
                                :AdminInfo (
                                        :chkpf_uid ("{D085D2C0-55C8-4491-9881-2FFF9ADDBDD2}")
                                        :ClassName (rule_source)
                                )
                                :compound ()
                                :op ()
                                : net-oslo
                        )
                )
                : (rule-3
                        :AdminInfo (
                                :chkpf_uid ("{434BA892-C6D4-41D3-B10F-CCD3DCC5624A}")
                                :ClassName (security_rule)
                        )
                        :action (
                                : ("Client Encrypt"
                                        :type (userc)
                                        :macro (USER_CLIENT_ENCRYPT)
                                        :src_options ("Intersect with User Database")
                                        :dst_options ("Intersect with User Database")
                                        :action (accept)
                                        :enforce_desktop_config (true)
                                )
                        )
                        :disabled (false)
                        :global_location (middle)
                        :through (
                                : (ReferenceObject
                                        :Name (Any)
                                )
                        )
                        :time (
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :track (
                                : Log
                        )
                        :dst (
                                :AdminInfo (
                                        :chkpf_uid ("{E438E443-EEC1-490C-B768-871DDBBEEC71}")
                                        :ClassName (rule_destination)
                                )
                                :compound ()
                                :op ()
                                : net-oslo
                        )
                        :install (
                                :AdminInfo (
                                        :chkpf_uid ("{521B34F2-FE75-417A-92C3-7DADBAE2C0E6}")
                                        :ClassName (rule_install)
                                )
                                :compound ()
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :services (
                                :AdminInfo (
                                        :chkpf_uid ("{F7E3BAFA-CEFC-4FF2-AA8A-129F284CB852}")
                                        :ClassName (rule_services)
                                )
                                :compound ()
                                :op ()
                                : http
                                : ftp
                        )
                        :src (
                                :AdminInfo (
                                        :chkpf_uid ("{CB88EB10-D2B0-4DB5-8BBE-B5049130DDF9}")
                                        :ClassName (rule_source)
                                )
                                :compound (
                                        : (SC_Users@Any
                                                :AdminInfo (
                                                        :chkpf_uid ("{C2CB4115-1CB9-4807-ACAD-FA29E7995FD9}")
                                                        :ClassName (rule_user_group)
                                                )
                                                :at (Any
                                                        :color (Blue)
                                                )
                                                :color (darkorange3)
                                                :type (usrgroup)
                                        )
                                )
                                :op ()
                        )
                )
                : (rule-4
                        :AdminInfo (
                                :chkpf_uid ("{E455E894-B1CC-4174-AD65-4C01A2D39FF1}")
                                :ClassName (security_rule)
                        )
                        :action (
                                : (drop
                                        :AdminInfo (
                                                :chkpf_uid ("{378360D1-731F-48C3-83D1-70B2BFA779CE}")
                                                :ClassName (drop_action)
                                                :table (setup)
                                        )
                                        :action ()
                                        :macro ()
                                        :type (drop)
                                )
                        )
                        :disabled (false)
                        :global_location (middle)
                        :through (
                                : (ReferenceObject
                                        :Name (Any)
                                        :Table (globals)
                                        :Uid ("{97AEB369-9AEA-11D5-BD16-0090272CCB30}")
                                )
                        )
                        :time (
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :track (
                                : None
                        )
                        :dst (
                                :AdminInfo (
                                        :chkpf_uid ("{E72C1106-3410-415A-B969-DAE98BA716B8}")
                                        :ClassName (rule_destination)
                                )
                                :compound ()
                                :op ()
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :install (
                                :AdminInfo (
                                        :chkpf_uid ("{006BA8BF-E123-484D-BE5A-FDAD9A762C2E}")
                                        :ClassName (rule_install)
                                )
                                :compound ()
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :services (
                                :AdminInfo (
                                        :chkpf_uid ("{DEADCE27-7A11-4610-ADE5-CC5094C0C56B}")
                                        :ClassName (rule_services)
                                )
                                :compound ()
                                :op ()
                                : (Any
                                        :color (Blue)
                                )
                        )
                        :src (
                                :AdminInfo (
                                        :chkpf_uid ("{E198F27B-6492-4F6B-B074-63AE2A4F4B3B}")
                                        :ClassName (rule_source)
                                )
                                :compound ()
                                :op ()
                                : (Any
                                        :color (Blue)
                                )
                        )
                )
        )
        :rules-adtr ()
        :party ()
        :if_info (
                : (172.22.102.1
                        :objtype (gw)
                        : (eth-s1p1c0
                                :ipaddr (172.22.102.1)
                                :has_addr_info (true)
                                :addr_table (valid_addrs_list1)
                                :overlap_nat (false)
                                :overlap_nat_src_addr ()
                                :overlap_nat_dst_addr ()
                                :overlap_nat_netmask (255.255.255.0)
                                :spooftrack (log)
                                :external (true)
                        )
                        : (eth-s1p2c0
                                :ipaddr (10.2.2.1)
                                :has_addr_info (true)
                                :addr_table (valid_addrs_list2)
                                :overlap_nat (false)
                                :overlap_nat_src_addr ()
                                :overlap_nat_dst_addr ()
                                :overlap_nat_netmask (255.255.255.0)
                                :spooftrack (log)
                                :external (false)
                        )
                )
        )
        :conf_params (
                : (172.22.102.1
                        : (vpnddcate
                                :type (bool)
                                :val (false)
                        )
                        : (ip_pool_securemote
                                :type (bool)
                                :val (false)
                        )
                        : (ip_pool_gw2gw
                                :type (bool)
                                :val (false)
                        )
                        : (save_data_conns
                                :type (bool)
                                :val (false)
                        )
                        : (ip_pool_unused_return_interval
                                :type (int)
                                :val (60)
                        )
                        : (fw_keep_old_conns
                                :type (bool)
                                :val (false)
                        )
                        : (fw_hmem_size
                                :type (int)
                                :val (6)
                        )
                        : (fw_hmem_maxsize
                                :type (int)
                                :val (30)
                        )
                        : (connections_limit
                                :type (int)
                                :val (25000)
                        )
                        : (connections_hashsize
                                :type (int)
                                :val (32768)
                        )
                        : (non_tcp_quota_percentage
                                :type (int)
                                :val (50)
                        )
                        : (non_tcp_quota_enable
                                :type (bool)
                                :val (false)
                        )
                        : (asm_synatk
                                :type (bool)
                                :val (false)
                        )
                        : (asm_synatk_timeout
                                :type (int)
                                :val (5)
                        )
                        : (asm_synatk_threshold
                                :type (int)
                                :val (200)
                        )
                        : (asm_synatk_external_only
                                :type (bool)
                                :val (true)
                        )
                        : (asm_synatk_log
                                :type (str)
                                :val (log)
                        )
                        : (asm_synatk_log_level
                                :type (int)
                                :val (1)
                        )
                        : (translation_cache_limit
                                :type (int)
                                :val (10000)
                        )
                        : (translation_cache_expiry
                                :type (int)
                                :val (1800)
                        )
                        : (no_nat_cache_service
                                :type (bool)
                                :val (true)
                        )
                        : (vpn_cluster_addr
                                :type (int)
                                :val (0)
                        )
                        : (availability_mode
                                :type (int)
                                :val (0)
                        )
                        : (fw_my_object_ip
                                :type (int)
                                :val (-1407818239)
                        )
                        : (vpn_udpencap_port
                                :type (int)
                                :val (2746)
                        )
                        : (EnableDecapsulation
                                :type (int)
                                :val (0)
                        )
                        : (support_L2TP
                                :type (int)
                                :val (0)
                        )
                        : (vpn_comp_level
                                :type (int)
                                :val (2)
                        )
                        : (ipsec_dont_fragment
                                :type (int)
                                :val (1)
                        )
                        : (IPSec_TOS_inner
                                :type (int)
                                :val (0)
                        )
                        : (IPSec_TOS_outer
                                :type (int)
                                :val (1)
                        )
                        : (is_ikehost
                                :type (int)
                                :val (1)
                        )
                        : (disable_replay_check
                                :type (int)
                                :val (0)
                        )
                        : (cphwd_round_robin
                                :type (int)
                                :val (0)
                        )
                        : (is_extranet_allowed
                                :type (int)
                                :val (0)
                        )
                        : (userc_rules_lm
                                :type (int)
                                :val (50000)
                        )
                        : (userc_rules_sz
                                :type (int)
                                :val (65536)
                        )
                        : (userc_key_lm
                                :type (int)
                                :val (10000)
                        )
                        : (userc_users_lm
                                :type (int)
                                :val (10000)
                        )
                        : (userc_users_sz
                                :type (int)
                                :val (16384)
                        )
                        : (inbound_SPI_lm
                                :type (int)
                                :val (20400)
                        )
                        : (inbound_SPI_sz
                                :type (int)
                                :val (32768)
                        )
                        : (outbound_SPI_lm
                                :type (int)
                                :val (20400)
                        )
                        : (outbound_SPI_sz
                                :type (int)
                                :val (32768)
                        )
                        : (MSPI_requests_lm
                                :type (int)
                                :val (10200)
                        )
                        : (MSPI_req_connections_lm
                                :type (int)
                                :val (25000)
                        )
                        : (SPI_requests_lm
                                :type (int)
                                :val (10200)
                        )
                        : (IKE_SA_table_lm
                                :type (int)
                                :val (40400)
                        )
                        : (IKE_SA_table_sz
                                :type (int)
                                :val (65536)
                        )
                        : (IPSEC_userc_dont_trap_table_lm
                                :type (int)
                                :val (10000)
                        )
                        : (userc_pending_lm
                                :type (int)
                                :val (10000)
                        )
                        : (MSPI_by_methods_lm
                                :type (int)
                                :val (10200)
                        )
                        : (MSPI_cluster_map_lm
                                :type (int)
                                :val (10200)
                        )
                        : (MSPI_cluster_feedback_lm
                                :type (int)
                                :val (10200)
                        )
                        : (L2TP_MSPI_cluster_feedback_lm
                                :type (int)
                                :val (10200)
                        )
                        : (MSPI_cluster_feedback_new_lm
                                :type (int)
                                :val (10200)
                        )
                        : (MSPI_feedback_to_delete_lm
                                :type (int)
                                :val (10200)
                        )
                        : (udp_enc_cln_table_lm
                                :type (int)
                                :val (20000)
                        )
                        : (udp_enc_cln_table_sz
                                :type (int)
                                :val (32768)
                        )
                        : (udp_response_nat_lm
                                :type (int)
                                :val (10200)
                        )
                        : (VIN_SA_to_delete_lm
                                :type (int)
                                :val (10200)
                        )
                        : (marcipan_ippool_allocated_lm
                                :type (int)
                                :val (10000)
                        )
                        : (marcipan_ippool_users_lm
                                :type (int)
                                :val (10000)
                        )
                        : (persistent_tunnels_lm
                                :type (int)
                                :val (10200)
                        )
                        : (L2TP_tunnels_lm
                                :type (int)
                                :val (10000)
                        )
                        : (L2TP_sessions_lm
                                :type (int)
                                :val (10000)
                        )
                        : (max_concurrent_vpn_tunnels
                                :type (int)
                                :val (10000)
                        )
                        : (max_concurrent_gw_tunnels
                                :type (int)
                                :val (200)
                        )
                        : (fwsynatk_method
                                :type (int)
                                :val (0)
                        )
                        : (fwsynatk_timeout
                                :type (int)
                                :val (10)
                        )
                        : (fwsynatk_max
                                :type (int)
                                :val (5000)
                        )
                        : (fwsynatk_warning
                                :type (int)
                                :val (1)
                        )
                        : (IPSec_cluster_nat
                                :type (int)
                                :val (0)
                        )
                        : (IPSec_main_if_nat
                                :type (int)
                                :val (0)
                        )
                        : (IPSec_orig_if_nat
                                :type (int)
                                :val (1)
                        )
                )
                : (__global__
                        : (conn_limit_notify_interval
                                :type (int)
                                :val (3600)
                        )
                        : (conn_limit_reached_log
                                :type (bool)
                                :val (true)
                        )
                        : (tcptimeout
                                :type (int)
                                :val (3600)
                        )
                        : (tcpstarttimeout
                                :type (int)
                                :val (25)
                        )
                        : (tcpendtimeout
                                :type (int)
                                :val (20)
                        )
                        : (sip_early_nat
                                :type (bool)
                                :val (false)
                        )
                        : (udpreply
                                :type (bool)
                                :val (true)
                        )
                        : (udpreply_from_any_port
                                :type (bool)
                                :val (false)
                        )
                        : (udptimeout
                                :type (int)
                                :val (40)
                        )
                        : (icmpreply
                                :type (bool)
                                :val (true)
                        )
                        : (icmperrors
                                :type (bool)
                                :val (true)
                        )
                        : (icmptimeout
                                :type (int)
                                :val (30)
                        )
                        : (otherreply
                                :type (bool)
                                :val (false)
                        )
                        : (othertimeout
                                :type (int)
                                :val (60)
                        )
                        : (dataconn_pendingtimeout
                                :type (int)
                                :val (60)
                        )
                        : (log_data_conns
                                :type (bool)
                                :val (false)
                        )
                        : (fw_tcp_seq_verify
                                :type (bool)
                                :val (true)
                        )
                        : (fw_tcp_seq_verify_log_level
                                :type (int)
                                :val (4)
                        )
                        : (fw_tcp_seq_verify_track_type
                                :type (str)
                                :val (log)
                        )
                        : (fw_virtual_defrag_log
                                :type (str)
                                :val (log)
                        )
                        : (addresstrans
                                :type (bool)
                                :val (true)
                        )
                        : (nat_automatic_rules_merge
                                :type (bool)
                                :val (true)
                        )
                        : (fwx_hide_extra_capacity
                                :type (bool)
                                :val (true)
                        )
                        : (hide_max_high_port
                                :type (int)
                                :val (60000)
                        )
                        : (hide_min_high_port
                                :type (int)
                                :val (10000)
                        )
                        : (hide_alloc_attempts
                                :type (int)
                                :val (50000)
                        )
                        : (fwx_ddcate_hide
                                :type (int)
                                :val (1)
                        )
                        : (fwx_ddcate_hide_non_crypt
                                :type (int)
                                :val (1)
                        )
                        : (stack_size
                                :type (int)
                                :val (0)
                        )
                        : (nrules
                                :type (int)
                                :val (4)
                        )
                        : (disable_ipsec
                                :type (bool)
                                :val (false)
                        )
                        : (logical_servers_active
                                :type (bool)
                                :val (false)
                        )
                        : (tcpestb_grace_period
                                :type (int)
                                :val (0)
                        )
                        : (tcp_reject
                                :type (bool)
                                :val (true)
                        )
                        : (udp_reject
                                :type (bool)
                                :val (true)
                        )
                        : (ip_pool_log
                                :type (int)
                                :val (1)
                        )
                        : (maintenance_notification
                                :type (str)
                                :val (log)
                        )
                        : (fw_dns_verification
                                :type (bool)
                                :val (true)
                        )
                        : (fw_dns_xlation
                                :type (bool)
                                :val (false)
                        )
                        : (sam_track
                                :type (str)
                                :val (alert)
                        )
                        : (loggrace
                                :type (int)
                                :val (62)
                        )
                        : (ipoptslog
                                :type (str)
                                :val (none)
                        )
                        : (fw_allow_out_of_state_tcp
                                :type (int)
                                :val (0)
                        )
                        : (fw_log_out_of_state_tcp
                                :type (int)
                                :val (1)
                        )
                        : (fw_log_out_of_state_udp
                                :type (int)
                                :val (0)
                        )
                        : (fw_log_out_of_state_icmp
                                :type (int)
                                :val (1)
                        )
                        : (fw_log_out_of_state_other
                                :type (int)
                                :val (0)
                        )
                        : (unify_ctl_data_acct_logs
                                :type (bool)
                                :val (false)
                        )
                        : (validate_desktop_security
                                :type (bool)
                                :val (false)
                        )
                        : (allow_h323_t120
                                :type (bool)
                                :val (false)
                        )
                        : (allow_h323_through_ras
                                :type (bool)
                                :val (true)
                        )
                        : (h323_log_conn
                                :type (bool)
                                :val (true)
                        )
                        : (fwh323_allow_redirect
                                :type (bool)
                                :val (false)
                        )
                        : (h323_init_mem
                                :type (bool)
                                :val (true)
                        )
                        : (fwh323_force_src_phone
                                :type (bool)
                                :val (true)
                        )
                        : (sip_allow_redirect
                                :type (bool)
                                :val (true)
                        )
                        : (sip_enforce_security_reinvite
                                :type (bool)
                                :val (true)
                        )
                        : (sip_max_reinvite
                                :type (int)
                                :val (3)
                        )
                        : (log_scv_drops
                                :type (str)
                                :val (log)
                        )
                        : (enable_ip_options
                                :type (int)
                                :val (1)
                        )
                        : (generate_nat_log
                                :type (int)
                                :val (1)
                        )
                        : (use_VPN_communities
                                :type (bool)
                                :val (true)
                        )
                        : (voip_allow_no_from
                                :type (bool)
                                :val (false)
                        )
                        : (PDU_sequence
                                :type (int)
                                :val (16)
                        )
                        : (gtp_sequence_deviation_alert
                                :type (int)
                                :val (1)
                        )
                        : (gtp_sequence_deviation_drop
                                :type (int)
                                :val (0)
                        )
                        : (allow_PDU_sequence
                                :type (int)
                                :val (0)
                        )
                        : (check_flow_labels
                                :type (int)
                                :val (1)
                        )
                        : (gtp_allow_recreate_pdpc
                                :type (str)
                                :val (open)
                        )
                        : (gtp_track
                                :type (str)
                                :val (log)
                        )
                        : (fw_clamp_tcp_mss
                                :type (bool)
                                :val (false)
                        )
                        : (cphwd_enable_templates
                                :type (bool)
                                :val (true)
                        )
                        : (asm_max_ping_limit
                                :type (bool)
                                :val (true)
                        )
                        : (asm_max_ping_limit_size
                                :type (int)
                                :val (64)
                        )
                        : (asm_max_ping_limit_log
                                :type (str)
                                :val (log)
                        )
                        : (asm_ftp_bounce_log
                                :type (str)
                                :val (log)
                        )
                        : (asm_dns_verify_log
                                :type (str)
                                :val (log)
                        )
                        : (asm_land
                                :type (bool)
                                :val (true)
                        )
                        : (asm_land_log
                                :type (str)
                                :val (log)
                        )
                        : (asm_http_worm_catcher
                                :type (bool)
                                :val (false)
                        )
                        : (asm_http_worm_catcher_log
                                :type (str)
                                :val (alert)
                        )
                        : (asm_http_worm1
                                :type (str)
                                :val (CodeRed)
                        )
                        : (asm_http_worm1_pattern
                                :type (str)
                                :val ("\.ida\?")
                        )
                        : (asm_http_worm2
                                :type (str)
                                :val (Nimda)
                        )
                        : (asm_http_worm2_pattern
                                :type (str)
                                :val ("(cmd\.exe)|(root\.exe)")
                        )
                        : (asm_http_worm3
                                :type (str)
                                :val ("htr overflow")
                        )
                        : (asm_http_worm3_pattern
                                :type (str)
                                :val ("\.htr\?")
                        )
                        : (asm_ping_of_death
                                :type (bool)
                                :val (true)
                        )
                        : (asm_ping_of_death_log
                                :type (str)
                                :val (log)
                        )
                        : (asm_packet_verify_log
                                :type (str)
                                :val (log)
                        )
                        : (asm_packet_verify_relaxed_udp
                                :type (bool)
                                :val (true)
                        )
                        : (asm_small_pmtu
                                :type (bool)
                                :val (false)
                        )
                        : (asm_small_pmtu_size
                                :type (int)
                                :val (350)
                        )
                        : (asm_small_pmtu_log
                                :type (str)
                                :val (log)
                        )
                        : (asm_teardrop
                                :type (bool)
                                :val (true)
                        )
                        : (asm_teardrop_log
                                :type (str)
                                :val (log)
                        )
                        : (icmpcryptver
                                :type (int)
                                :val (1)
                        )
                        : (fwz_encap_mtu
                                :type (int)
                                :val (1)
                        )
                        : (vpn_conf_n_key_exch_prob
                                :type (str)
                                :val (log)
                        )
                        : (vpn_packet_handle_prob
                                :type (str)
                                :val (log)
                        )
                        : (vpn_success_key_exch
                                :type (str)
                                :val (log)
                        )
                        : (acceptdecrypt
                                :type (int)
                                :val (0)
                        )
                        : (sr_same_ip_log
                                :type (int)
                                :val (1)
                        )
                        : (sr_same_ip_block
                                :type (int)
                                :val (0)
                        )
                        : (sync_outbound_sa_pkt_count
                                :type (int)
                                :val (200000)
                        )
                        : (community_based_policy
                                :type (int)
                                :val (1)
                        )
                        : (fwsynatk_method
                                :type (int)
                                :val (0)
                        )
                        : (fwsynatk_timeout
                                :type (int)
                                :val (5)
                        )
                        : (fwsynatk_max
                                :type (int)
                                :val (5000)
                        )
                        : (fwsynatk_warning
                                :type (int)
                                :val (1)
                        )
                        : (nat_limit
                                :type (int)
                                :val (0)
                        )
                        : (nat_hashsize
                                :type (int)
                                :val (0)
                        )
                        : (fwfrag_limit
                                :type (int)
                                :val (0)
                        )
                        : (fwfrag_timeout
                                :type (int)
                                :val (0)
                        )
                        : (fwfrag_minsize
                                :type (int)
                                :val (0)
                        )
                        : (IPSec_cluster_nat
                                :type (int)
                                :val (0)
                        )
                        : (IPSec_main_if_nat
                                :type (int)
                                :val (0)
                        )
                        : (IPSec_orig_if_nat
                                :type (int)
                                :val (0)
                        )
                )
        )
)