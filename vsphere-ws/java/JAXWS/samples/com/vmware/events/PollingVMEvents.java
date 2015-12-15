/***************************************************************************
 * Copyright (c) 2015 VMware, Inc. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ***************************************************************************/
package com.vmware.events;

import com.vmware.common.annotations.Action;
import com.vmware.common.annotations.Option;
import com.vmware.common.annotations.Sample;
import com.vmware.connection.ConnectedVimServiceBase;
import com.vmware.vim25.*;
import org.apache.commons.collections.CollectionUtils;

import java.util.List;
import java.util.Map;

import static java.lang.System.out;

/**
 * <pre>
 * VMEventHistoryCollectorMonitor
 *
 * This sample is responsible for creating EventHistoryCollector
 * filtered for a single VM and monitoring Events using the
 * latestPage attribute of the EventHistoryCollector.
 *
 * <b>Parameters:</b>
 * url        [required] : url of the web service
 * username   [required] : username for the authentication
 * password   [required] : password for the authentication
 * vmname     [required] : virtual machine name
 *
 * <b>Command Line:</b>
 * run.bat com.vmware.events.PollingVMEvents --url [webserviceurl]
 * --username [username] --password  [password] --vmname  [vm name]
 * </pre>
 *
 * Created by xiaoliangl on 12/15/15.
 */

@Sample(
      name = "vmevent-poller",
      description = "This sample is responsible for creating EventHistoryCollector " +
            "filtered for a single VM and monitoring Events using the " +
            "latestPage attribute of the EventHistoryCollector."
)
public class PollingVMEvents extends ConnectedVimServiceBase {
   private ManagedObjectReference propCollectorRef;
   private ManagedObjectReference eventManagerRef;
   private ManagedObjectReference eventHistoryCollectorRef;

   private ManagedObjectReference vmRef;

   private String vmName;

   private String version;

   @Option(name = "vmname", description = "virtual machine name")
   public void setVmName(String name) {
      this.vmName = name;
   }

   /**
    * Creates the event history collector.
    *
    * @throws Exception the exception
    */
   void createEventHistoryCollector() throws RuntimeFaultFaultMsg, InvalidStateFaultMsg {

      EventFilterSpecByEntity entitySpec = new EventFilterSpecByEntity();
      entitySpec.setEntity(vmRef);
      entitySpec.setRecursion(EventFilterSpecRecursionOption.ALL);
      EventFilterSpec eventFilter = new EventFilterSpec();
      eventFilter.setEntity(entitySpec);
      eventHistoryCollectorRef =
            vimPort.createCollectorForEvents(eventManagerRef, eventFilter);
   }

   /**
    * Creates the event filter Spec.
    *
    * @return the PropertyFilterSpec
    */
   PropertyFilterSpec createEventFilterSpec() {
      PropertySpec propSpec = new PropertySpec();
      propSpec.setAll(new Boolean(false));

      propSpec.getPathSet().add("latestPage");
      propSpec.setType(eventHistoryCollectorRef.getType());

      ObjectSpec objSpec = new ObjectSpec();
      objSpec.setObj(eventHistoryCollectorRef);
      objSpec.setSkip(new Boolean(false));

      PropertyFilterSpec spec = new PropertyFilterSpec();
      spec.getPropSet().add(propSpec);
      spec.getObjectSet().add(objSpec);
      return spec;
   }

   @Action
   public void run() throws RuntimeFaultFaultMsg, InvalidPropertyFaultMsg, InvalidStateFaultMsg, InterruptedException {
      propCollectorRef = serviceContent.getPropertyCollector();
      eventManagerRef = serviceContent.getEventManager();
      Map<String, ManagedObjectReference> vms = getMOREFs.inContainerByType(serviceContent
            .getRootFolder(), "VirtualMachine");
      vmRef = vms.get(vmName);

      if (vmRef != null) {
         createEventHistoryCollector();
         PropertyFilterSpec eventFilterSpec = createEventFilterSpec();
         ManagedObjectReference filterRef = vimPort.createFilter(propCollectorRef, eventFilterSpec, false);

         try {
            out.println("start to drain old events");
            drainEvents();
            out.println("finish to drain old events");

            while (true) {
               pollVMEvents(vmRef);

               Thread.sleep(1000);
            }
         } finally {
            vimPort.destroyPropertyFilter(filterRef);
         }
      } else {
         System.out.println("Virtual Machine " + vmName + " Not Found.");
         return;
      }
   }

   private void drainEvents() throws RuntimeFaultFaultMsg {
      List<Event> readEvents = vimPort.readNextEvents(eventHistoryCollectorRef, 100);
      out.println("readEvents count: " + readEvents.size());
      while (CollectionUtils.isNotEmpty(readEvents)) {
         for(Event event : readEvents) {
            out.println("read event: " + event.getFullFormattedMessage() + event.getCreatedTime().toString());
         }

         readEvents = vimPort.readNextEvents(eventHistoryCollectorRef, 100);
         out.println("readEvents count: " + readEvents.size());
      }
   }

   private void pollVMEvents(ManagedObjectReference vmRef) {
      WaitOptions waitOptions = new WaitOptions();
      waitOptions.setMaxWaitSeconds(5);

      try {
         UpdateSet updateSet = vimPort.waitForUpdatesEx(propCollectorRef, version, waitOptions);

         if(updateSet == null) {
            out.println("updateSet is empty");
         }
         else {
            List<PropertyFilterUpdate> filterSet = updateSet.getFilterSet();
            if (CollectionUtils.isEmpty(filterSet)) {
               out.println("PropertyFilterUpdateSet is empty");
            } else {
               out.println("PropertyFilterUpdateSet is not empty");
               for (PropertyFilterUpdate pfu : filterSet) {
                  for (ObjectUpdate objectUpdate : pfu.getObjectSet()) {
                     //out.println("objectUpdate kind: " + objectUpdate.getKind());
                     //out.println("objectUpdate obj: " + objectUpdate.getObj().getType());
                     for(PropertyChange propertyChange : objectUpdate.getChangeSet()) {
                        //out.println(propertyChange.getName());
                        //out.println(propertyChange.getOp());
                        Object val = propertyChange.getVal();

                        if(val instanceof ArrayOfEvent) {
                           /*ArrayOfEvent arrayOfEvent = (ArrayOfEvent) val;
                           List<Event> eventList = arrayOfEvent.getEvent();
                           for(Event event : eventList) {
                              out.println("notified event: " + event.getFullFormattedMessage() + event.getCreatedTime().toString());
                              events updates are not accurate!! still need to read events
                           }*/

                           drainEvents();
                        }
                     }
                  }
               }

               version = updateSet.getVersion();
               out.println("end process event updates");
            }
         }

      } catch (InvalidCollectorVersionFaultMsg invalidCollectorVersionFaultMsg) {
         invalidCollectorVersionFaultMsg.printStackTrace();
      } catch (RuntimeFaultFaultMsg runtimeFaultFaultMsg) {
         runtimeFaultFaultMsg.printStackTrace();
      }
   }
}
