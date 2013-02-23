package org.ziptie.adaptertool;

/**
 * Supported adapter operations
 * Operations
 */
public enum Operation
{
    /**
     * backup is the primary and default adapter operation
     */
    backup,

    /**
     * Restore is the adapter's way of moving files from the server to the device
     */
    restore,

    /**
     * Commands is an abstract way of executing any series of commands on a device
     */
    commands,

    /**
     * Pull an operating system image or images from the network device
     */
    ospull,

    /**
     * Create a DiscoveryEvent via an adapter operation
     */
    telemetry,
}
