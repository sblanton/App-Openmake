package com.seanblanton.openmake;

import java.util.Date;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import com.openmake.generated.TaskList;
import com.openmake.integration.OMClient;
import com.openmake.integration.OMServerInterface;
import com.openmake.integration.ServerInterfaceException;

public class Job implements org.quartz.Job {

	private static Logger log = LoggerFactory.getLogger(Job.class);

	OMClient omClient = null;
	OMServerInterface osi = null;

	String buildJobName = null;
	String OPENMAKE_SERVER = null;

	/**
	 * Constructor for job initilization
	 */
	public Job(String OPENMAKE_SERVER, String buildJobName) {
		this.buildJobName = buildJobName;
		this.OPENMAKE_SERVER = OPENMAKE_SERVER;
//		getOPENMAKE_SERVER();
		setupOMClient();
		connectServer();
	}

	public OMClient setupOMClient() {

		String sKBAddress = null;

		// construct OMClient and set up the required variables
		System.out.println("Constructing OMClient");
		if (omClient == null) {
			omClient = new OMClient();
		}
		// set OMClient.HTMLServer
		// omFileManager = omClient.getFileManager();

//		String OPENMAKE_SERVER = this.getOPENMAKE_SERVER();

		log.info("Connecting to " + OPENMAKE_SERVER);

		omClient.setHTMLServer(OPENMAKE_SERVER);
		log.info("Set OMClient.HTMLServer to: " + OPENMAKE_SERVER);

		// set OMClient.KBAddress
		int i = OPENMAKE_SERVER.lastIndexOf('/');
		sKBAddress = OPENMAKE_SERVER.substring(0, i)
				+ "/soap/servlet/openmakeserver";
		omClient.setKBAddress(sKBAddress);
		log.info("Set OMClient.KBAddress to: " + sKBAddress);

		return omClient;
	}

	/*
	 * Method to get the OPENMAKE_SERVER property
	 */

//	public String getOPENMAKE_SERVER() {
//		log.info("OPENMAKE_SERVER=" + System.getenv("OPENMAKE_SERVER"));
//		return "http://choppercermak31:58080/openmake";
//		//return System.getenv("OPENMAKE_SERVER");
//
//	}

	/**
	 * Example method that connects to the Knowledge Base Server using the
	 * OMClient API. OMServerInterface osi = null;
	 * @return OMServerInteface
	 */
	public OMServerInterface connectServer() {
		OMServerInterface osi = null;

		try {
			System.out.println("Connecting to the Server...");
			osi = omClient.connect();
			System.out.println("Successfully connected to the Server");
			
		} catch (ServerInterfaceException sie) {
			System.out.println("Error while connecting to the server: "
					+ sie.getMessage());
			System.out.println("Exiting MB_API_TEST.");
			System.exit(0);
			
		}

		return osi;
	}
	
	public void executeBuildJob() throws Exception {

		try {
			log.info("Executing: Mojo Job " + buildJobName + " executing at "
					+ new Date());
			TaskList buildJob = omClient.getBuildJob(true, buildJobName);
			omClient.executeBuildJob(buildJob);
			log.info(buildJobName + " executed successfully.");
		} catch (ServerInterfaceException sie) {
			log.error(sie.getMessage());
		}
	}

	public void execute(JobExecutionContext context)
			throws JobExecutionException {

		// This job simply prints out its job name and the
		// date and time that it is running
		String jobName = context.getJobDetail().getFullName();
		log.info("Quartz says: " + jobName + " executing at " + new Date());
		try {
			executeBuildJob();
		} catch (Exception e) {
			log.error(e.getMessage());
		}
	}
	
//    public static void main(String[] args) throws Exception {
//
//        MojoJob mj = new MojoJob();
//		log.info("MojoJob.main says: executing at " + new Date());
//        mj.executeBuildJob();
//
//    }

}
