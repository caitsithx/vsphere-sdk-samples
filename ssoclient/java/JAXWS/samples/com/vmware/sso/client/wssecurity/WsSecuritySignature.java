/* **********************************************************
 * Copyright 2012 VMware, Inc.  All rights reserved.
 *
 * VMware Confidential
 * **********************************************************/
package com.vmware.sso.client.wssecurity;

import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;
import java.security.SignatureException;

/**
 * Interface used for signing the SOAP requests
 *
 * @author Ecosystem Engineering
 */
public interface WsSecuritySignature {

   /**
    * Signs the SOAP Message
    *
    * @param message
    * @return
    * @throws SignatureException
    * @throws SOAPException
    */
   public SOAPMessage sign(SOAPMessage message) throws SignatureException,
         SOAPException;
}
