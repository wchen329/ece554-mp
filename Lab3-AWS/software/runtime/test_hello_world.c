// Amazon FPGA Hardware Development Kit
//
// Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Copyright 2019 Yuhua Chen and Winor Chen. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License"). You may not use
// this file except in compliance with the License. A copy of the License is
// located at
//
//    http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
// implied. See the License for the specific language governing permissions and
// limitations under the License.
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <assert.h>
#include <string.h>

#ifdef SV_TEST
   #include "fpga_pci_sv.h"
#else
   #include <fpga_pci.h>
   #include <fpga_mgmt.h>
   #include <utils/lcd.h>
#endif

#include <utils/sh_dpi_tasks.h>

/* Constants determined by the CL */
/* a set of register offsets; this CL has only one */
/* these register addresses should match the addresses in */
/* /aws-fpga/hdk/cl/examples/common/cl_common_defines.vh */
/* SV_TEST macro should be set if SW/HW co-simulation should be enabled */
#define HELLO_WORLD_REG_ADDR UINT64_C(0x500)
#define VLED_REG_ADDR	UINT64_C(0x504)
#define CONV_IN_0_REG_ADDR UINT64_C(0x508)
#define CONV_IN_1_REG_ADDR UINT64_C(0x50C)
#define CONV_IN_2_REG_ADDR UINT64_C(0x510)
#define CONV_IN_3_REG_ADDR UINT64_C(0x514)
#define CONV_IN_4_REG_ADDR UINT64_C(0x518)
#define CONV_IN_5_REG_ADDR UINT64_C(0x51C)
#define CONV_IN_6_REG_ADDR UINT64_C(0x520)
#define CONV_IN_7_REG_ADDR UINT64_C(0x524)
#define CONV_IN_8_REG_ADDR UINT64_C(0x528)
#define CONV_MODE_REG_ADDR UINT64_C(0x52C)

/* use the stdout logger for printing debug information  */
#ifndef SV_TEST
const struct logger *logger = &logger_stdout;
/*
 * pci_vendor_id and pci_device_id values below are Amazon's and avaliable to use for a given FPGA slot. 
 * Users may replace these with their own if allocated to them by PCI SIG
 */
static uint16_t pci_vendor_id = 0x1D0F; /* Amazon PCI Vendor ID */
static uint16_t pci_device_id = 0xF000; /* PCI Device ID preassigned by Amazon for F1 applications */

/*
 * check if the corresponding AFI for hello_world is loaded
 */
int check_afi_ready(int slot_id);

void usage(char* program_name) {
    printf("usage: %s [--slot <slot-id>][<poke-value>]\n", program_name);
}

int32_t convolve_h(int32_t value);
int32_t convolve_v(int32_t value);

#endif

/*
 * An example to attach to an arbitrary slot, pf, and bar with register access.
 */
int peek_poke_example(uint32_t value, int slot_id, int pf_id, int bar_id);

int32_t coeffs_v[3][3];
int32_t coeffs_h[3][3];
/* Perform a convolution of 9 values.
 * Once again, the input values are arranged in this manner
 *
 * [HORIZONAL]
 */
int32_t convolve_h(int32_t** conv_in)
{
	int32_t y_h = 0;

	for(int32_t m = 0; m < 3; m++)
	{
		for(int32_t n = 0; n < 3; n++)
		{
			y_h += conv_in[2 - m][2 - n] * coeffs_h[m][n];
		}
	}

	return y_h;
}

/* Perform a convolution of 9 values.
 * Once again, the input values are arranged in this manner
 *
 * [VERTICAL]
 */
int32_t convolve_v(int32_t** conv_in)
{
	int32_t y_v = 0;

	for(int32_t m = 0; m < 3; m++)
	{
		for(int32_t n = 0; n < 3; n++)
		{
			y_v += conv_in[2 - m][2 - n] * coeffs_v[m][n];
		}
	}

	return y_v;
}

#ifdef SV_TEST
//For cadence and questa simulators the main has to return some value
# ifdef INT_MAIN
int test_main(uint32_t *exit_code)
# else 
void test_main(uint32_t *exit_code)
# endif 
#else 
int main(int argc, char **argv)
#endif
{
	// Set my convolution coefficients
	coeffs_v[0][0] = -1;
	coeffs_v[0][1] = 0;
	coeffs_v[0][2] = 1;
	coeffs_v[1][0] = -2;
	coeffs_v[1][1] = 0;
	coeffs_v[1][2] = 2;
	coeffs_v[2][0] = -1;
	coeffs_v[2][1] = 0;
	coeffs_v[2][2] = 1;

	coeffs_h[0][0] = -1;
	coeffs_h[0][1] = -2;
	coeffs_h[0][2] = -1;
	coeffs_h[1][0] = 0;
	coeffs_h[1][1] = 0;
	coeffs_h[1][2] = 0;
	coeffs_h[2][0] = 1;
	coeffs_h[2][1] = 2;
	coeffs_h[2][2] = 1;

    //The statements within SCOPE ifdef below are needed for HW/SW co-simulation with VCS
    #ifdef SCOPE
      svScope scope;
      scope = svGetScopeFromName("tb");
      svSetScope(scope);
    #endif

    uint32_t value = 0xefbeadde;
    int slot_id = 0;
    int rc;
    
#ifndef SV_TEST
    // Process command line args
    {
        int i;
        int value_set = 0;
        for (i = 1; i < argc; i++) {
            if (!strcmp(argv[i], "--slot")) {
                i++;
                if (i >= argc) {
                    printf("error: missing slot-id\n");
                    usage(argv[0]);
                    return 1;
                }
                sscanf(argv[i], "%d", &slot_id);
            } else if (!value_set) {
                sscanf(argv[i], "%x", &value);
                value_set = 1;
            } else {
                printf("error: Invalid arg: %s", argv[i]);
                usage(argv[0]);
                return 1;
            }
        }
    }
#endif

    /* initialize the fpga_mgmt library */
    rc = fpga_mgmt_init();
    fail_on(rc, out, "Unable to initialize the fpga_mgmt library");

#ifndef SV_TEST
    rc = check_afi_ready(slot_id);
    fail_on(rc, out, "AFI not ready");
#endif

    
    /* Accessing the CL registers via AppPF BAR0, which maps to sh_cl_ocl_ AXI-Lite bus between AWS FPGA Shell and the CL*/

    printf("===== Starting with peek_poke_example =====\n");
    rc = peek_poke_example(value, slot_id, FPGA_APP_PF, APP_PF_BAR0);
    fail_on(rc, out, "peek-poke example failed");

    printf("Developers are encouraged to modify the Virtual DIP Switch by calling the linux shell command to demonstrate how AWS FPGA Virtual DIP switches can be used to change a CustomLogic functionality:\n");
    printf("$ fpga-set-virtual-dip-switch -S (slot-id) -D (16 digit setting)\n\n");
    printf("In this example, setting a virtual DIP switch to zero clears the corresponding LED, even if the peek-poke example would set it to 1.\nFor instance:\n");

    printf(
        "# sudo fpga-set-virtual-dip-switch -S 0 -D 1111111111111111\n"
        "# sudo fpga-get-virtual-led  -S 0\n"
        "FPGA slot id 0 have the following Virtual LED:\n"
        "1010-1101-1101-1110\n"
        "# sudo fpga-set-virtual-dip-switch -S 0 -D 0000000000000000\n"
        "# sudo fpga-get-virtual-led  -S 0\n"
        "FPGA slot id 0 have the following Virtual LED:\n"
        "0000-0000-0000-0000\n"
    );

#ifndef SV_TEST
    return rc;
    
out:
    return 1;
#else

out:
   #ifdef INT_MAIN
   *exit_code = 0;
   return 0;
   #else 
   *exit_code = 0;
   #endif
#endif
}

/* As HW simulation test is not run on a AFI, the below function is not valid */
#ifndef SV_TEST

int check_afi_ready(int slot_id) {
   struct fpga_mgmt_image_info info = {0}; 
   int rc;

   /* get local image description, contains status, vendor id, and device id. */
   rc = fpga_mgmt_describe_local_image(slot_id, &info,0);
   fail_on(rc, out, "Unable to get AFI information from slot %d. Are you running as root?",slot_id);

   /* check to see if the slot is ready */
   if (info.status != FPGA_STATUS_LOADED) {
     rc = 1;
     fail_on(rc, out, "AFI in Slot %d is not in READY state !", slot_id);
   }

   printf("AFI PCI  Vendor ID: 0x%x, Device ID 0x%x\n",
          info.spec.map[FPGA_APP_PF].vendor_id,
          info.spec.map[FPGA_APP_PF].device_id);

   /* confirm that the AFI that we expect is in fact loaded */
   if (info.spec.map[FPGA_APP_PF].vendor_id != pci_vendor_id ||
       info.spec.map[FPGA_APP_PF].device_id != pci_device_id) {
     printf("AFI does not show expected PCI vendor id and device ID. If the AFI "
            "was just loaded, it might need a rescan. Rescanning now.\n");

     rc = fpga_pci_rescan_slot_app_pfs(slot_id);
     fail_on(rc, out, "Unable to update PF for slot %d",slot_id);
     /* get local image description, contains status, vendor id, and device id. */
     rc = fpga_mgmt_describe_local_image(slot_id, &info,0);
     fail_on(rc, out, "Unable to get AFI information from slot %d",slot_id);

     printf("AFI PCI  Vendor ID: 0x%x, Device ID 0x%x\n",
            info.spec.map[FPGA_APP_PF].vendor_id,
            info.spec.map[FPGA_APP_PF].device_id);

     /* confirm that the AFI that we expect is in fact loaded after rescan */
     if (info.spec.map[FPGA_APP_PF].vendor_id != pci_vendor_id ||
         info.spec.map[FPGA_APP_PF].device_id != pci_device_id) {
       rc = 1;
       fail_on(rc, out, "The PCI vendor id and device of the loaded AFI are not "
               "the expected values.");
     }
   }
    
   return rc;
 out:
   return 1;
}

#endif

/* Sets the FPGA state as necessary
 */
void prepare_fpga_state(int32_t ** in)
{
	// Write register values,
	// This prepares the input values to the convolution
	rc = fpga_pci_poke(pci_bar_handle, CONV_IN_0_REG_ADDR, in[0][0]);
    fail_on(rc, out, "Unable to write input 0 to the fpga !");

	rc = fpga_pci_poke(pci_bar_handle, CONV_IN_1_REG_ADDR, in[0][1]);
    fail_on(rc, out, "Unable to write input 1 to the fpga !");

	rc = fpga_pci_poke(pci_bar_handle, CONV_IN_2_REG_ADDR, in[0][2]);
    fail_on(rc, out, "Unable to write input 2 to the fpga !");

	rc = fpga_pci_poke(pci_bar_handle, CONV_IN_3_REG_ADDR, in[1][0]);
    fail_on(rc, out, "Unable to write input 3 to the fpga !");

	rc = fpga_pci_poke(pci_bar_handle, CONV_IN_4_REG_ADDR, in[1][1]);
    fail_on(rc, out, "Unable to write input 4 to the fpga !");

	rc = fpga_pci_poke(pci_bar_handle, CONV_IN_5_REG_ADDR, in[1][2]);
    fail_on(rc, out, "Unable to write input 5 to the fpga !");

	rc = fpga_pci_poke(pci_bar_handle, CONV_IN_6_REG_ADDR, in[2][0]);
    fail_on(rc, out, "Unable to write input 6 to the fpga !");

	rc = fpga_pci_poke(pci_bar_handle, CONV_IN_7_REG_ADDR, in[2][1]);
    fail_on(rc, out, "Unable to write input 7 to the fpga !");

	rc = fpga_pci_poke(pci_bar_handle, CONV_IN_8_REG_ADDR, in[2][2]);
    fail_on(rc, out, "Unable to write input 8 to the fpga !");
}

/* This sets the current convolution mode
 * of the FPGA Convolution Engine
 */
void set_convolution_mode_horz(int isHorz)
{
	if(isHorz)
	{
		rc = fpga_pci_poke(pci_bar_handle, CONV_MODE_REG_ADDR, 1);
		fail_on(rc, out, "Unable to write Convolution Mode (horizontal) !");
	}

	else
	{
		rc = fpga_pci_poke(pci_bar_handle, CONV_MODE_REG_ADDR, 0);
		fail_on(rc, out, "Unable to write Convolution Mode (vertical) !");
	}
}

/*
 * An example to attach to an arbitrary slot, pf, and bar with register access.
 */
int peek_poke_example(uint32_t value, int slot_id, int pf_id, int bar_id) {
    int rc;
    /* pci_bar_handle_t is a handler for an address space exposed by one PCI BAR on one of the PCI PFs of the FPGA */

    pci_bar_handle_t pci_bar_handle = PCI_BAR_HANDLE_INIT;

    
    /* attach to the fpga, with a pci_bar_handle out param
     * To attach to multiple slots or BARs, call this function multiple times,
     * saving the pci_bar_handle to specify which address space to interact with in
     * other API calls.
     * This function accepts the slot_id, physical function, and bar number
     */
#ifndef SV_TEST
    rc = fpga_pci_attach(slot_id, pf_id, bar_id, 0, &pci_bar_handle);
    fail_on(rc, out, "Unable to attach to the AFI on slot id %d", slot_id);
#endif
    
	// Test input
	int32_t conv_in[3][3] = { 1, 2, 3, 4, 5, 6, 7, 8, 9 };

    /* write a value into the mapped address space */
    uint32_t expected_v = convolve_v(conv_in); // expected value from convolution (vertical)
	uint32_t expected_h = convolve_h(conv_in); // expected value from convolution (horizontal)

	// Set register values
	prepare_fpga_state(conv_in);

	/* HORIZONTAL CONVOLUTION
	 * (todo: enable convolution in hardware)
	 */

	printf("Writing the expected convolution value (of horizontal) to registers...\n");
	int32_t fpga_h_output;
	set_convolution_mode_horz(1);

    /* read it back and print it out; you should expect the byte order to be
     * reversed (That's what this CL does) */
    rc = fpga_pci_peek(pci_bar_handle, HELLO_WORLD_REG_ADDR, &fpga_h_output);
    fail_on(rc, out, "Unable to read read from the fpga !");
    if(value == expected_h) {
        printf("TEST PASSED");
        printf("Resulting value for Horizontal Conv. matched expected value 0x%x. It worked!\n", expected);
    }
    else{
        printf("TEST FAILED");
        printf("Resulting value for Horizontal Conv. did not match expected value 0x%x. Something didn't work.\n", expected);
    }

	/* VERTICAL CONVOLUTION
	 * (todo: enable convolution in hardware)
	 */
	printf("Writing the expected convolution value (of vertical) to registers...\n");
	int32_t fpga_v_output;
	set_convolution_mode_horz(0);

    fail_on(rc, out, "Unable to write to the fpga !");

    /* read it back and print it out; you should expect the byte order to be
     * reversed (That's what this CL does) */
    rc = fpga_pci_peek(pci_bar_handle, HELLO_WORLD_REG_ADDR, &fpga_v_output);
    fail_on(rc, out, "Unable to read read from the fpga !");
    if(value == expected_v) {
        printf("TEST PASSED");
        printf("Resulting value for Vertical Conv. matched expected value 0x%x. It worked!\n", expected);
    }
    else{
        printf("TEST FAILED");
        printf("Resulting value for Vertical Conv. did not match expected value 0x%x. Something didn't work.\n", expected);
    }



out:
    /* clean up */
    if (pci_bar_handle >= 0) {
        rc = fpga_pci_detach(pci_bar_handle);
        if (rc) {
            printf("Failure while detaching from the fpga.\n");
        }
    }

    /* if there is an error code, exit with status 1 */
    return (rc != 0 ? 1 : 0);

}

#ifdef SV_TEST
/*This function is used transfer string buffer from SV to C.
  This function currently returns 0 but can be used to update a buffer on the 'C' side.*/
int send_rdbuf_to_c(char* rd_buf)
{
   return 0;
}

#endif
