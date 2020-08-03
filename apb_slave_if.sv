
interface apb_slave_if(input pclock, preset);
  // Actual Signals
   parameter         PADDR_WIDTH  = 32;
   parameter         PWDATA_WIDTH = 32;
   parameter         PRDATA_WIDTH = 32;

  // Control flags
  bit                has_checks = 1;
  bit                has_coverage = 1;

  // Actual Signals
  //wire logic              pclock;
  //wire logic              preset;
  wire logic       [PADDR_WIDTH-1:0] paddr;
  wire logic              prwd;
  wire logic       [PWDATA_WIDTH-1:0] pwdata;
  wire logic              psel;
  wire logic              penable;

  logic        [PRDATA_WIDTH-1:0] prdata;
  logic              pslverr;
  logic              pready;

  // Coverage and assertions to be implegmented here.

/*  fix to make concurrent assertions
always @(posedge pclock)
begin
// Pready must not be X or Z
assertPreadyUnknown:assert property (
                  disable iff(!has_checks) 
                  (!($isunknown(pready))))
                  else
                    $error("ERR_APB100_PREADY_XZ\n Pready went to X or Z");
// Pslverr must not be X or Z
assertPslverrUnknown:assert property (
                  disable iff(!has_checks) 
                  ((psel == 1'b0 or pready == 1'b0 or !($isunknown(pslverr)))))
                  else  
                    $error("ERR_APB101_PSLVERR_XZ\n Pslverr went to X or Z when responding");
// Prdata must not be X or Z
assertPrdataUnknown:assert property (
                  disable iff(!has_checks) 
                  ((psel == 1'b0 or pready == 0 or prwd == 0 or !($isunknown(prdata)))))
                  else
                  $error("ERR_APB102_XZ\n Prdata went to X or Z when responding to a read transfer");
end
   // EACH SLAVE HAS ITS OWN PSEL LINES FOR WHICH THE APB ABV VIP Checker can be run on.
`include "apb_checker.sv"
*/

endinterface : apb_slave_if
