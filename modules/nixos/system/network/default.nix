{ config, lib, ... }:
let
  cfg = config.vix.system.network;
in
{
  options.vix.system.network = {
    enable = lib.mkEnableOption "Extreme network performance optimizations";
  };

  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = {
      # 启用 BBR 拥塞控制
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";

      # TCP 窗口与缓冲区深度优化 (适合万兆/高带宽延迟积环境)
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;

      # 提高网络设备积压队列上限
      "net.core.netdev_max_backlog" = 5000;

      # 开启 TCP Fast Open (发送/接收均开启)
      "net.ipv4.tcp_fastopen" = 3;

      # 启用 MTU 探测, 解决因 ICMP 被拦截导致的路径 MTU 问题
      "net.ipv4.tcp_mtu_probing" = 1;

      # 优化响应能力
      "net.ipv4.tcp_low_latency" = 1;

      # 允许更高的连接并发
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_max_tw_buckets" = 2000000;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 10;
    };

    # 启用 NetworkManager 并保持基础配置
    networking.networkmanager.enable = true;
    networking.useDHCP = lib.mkDefault true;
  };
}
