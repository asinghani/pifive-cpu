"""
    Testbench wrapper. Handles:
        - Verilator compilation
        - VCD file output
        - DUT evaluation
        - DUT clocking
        - DUT I/O wrapping
        - Assertions
"""
import pyverilator
import ctypes

def asserteq(x, expected, msg=None):
    if x != expected:
        out_msg = ("- " + msg) if (msg is not None) else ("")
        print("Error: expected {}, got {} {}".format(expected, x, out_msg))
        raise AssertionError

class Testbench:
    """
        Compile and set up the verilator testbench.
    """
    def __init__(self, top_module_file, test_name, clk_port_name="i_clk", params={}, verilog_path=[], verilator_args=["-O3"], extra_cflags="-O3", tick_callbacks=[], quiet=True):
        self.sim = pyverilator.PyVerilator.build(
            top_module_file,
            verilog_path=[".."] + verilog_path,
            verilator_args=verilator_args,
            extra_cflags=extra_cflags,
            params=params,
            quiet=quiet
        )

        self.sim.auto_eval = False
        self.sim.start_vcd_trace("{}.vcd".format(test_name))
        self.sim.auto_tracing_mode = None

        self.dump_to_trace = self.sim.lib.add_to_vcd_trace
        self.dump_to_trace.argtypes = [ctypes.c_void_p, ctypes.c_int]
        self.time = 10

        self.dut = self.sim.io
        self._clk = self.write_port(clk_port_name)

        try:
            self.tick_callbacks = list(tick_callbacks)
        except:
            self.tick_callbacks = [tick_callbacks]

    """
        Add a callback to be executed on every clock tick.
    """
    def add_tick_callback(self, cb):
        self.tick_callbacks.append(cb)

    """
        Returns a function that reads from the given port when called.
    """
    def read_port(self, name):
        def func():
            return self.dut[name].value

        return func

    """
        Returns a function that writes to the given port when called.
    """
    def write_port(self, name):
        def func(value):
            self.dut[name] = value

        return func

    """
        Tick the clock forward `n` ticks (default 1).
        If `cb` is specified, it will be called before each tick.
    """ 
    def tick(self, n=1, cb=None):
        if cb is None:
            for i in range(n):
                self.sim.eval()
                self.dump_to_trace(self.sim.vcd_trace, self.time - 5)
                self._clk(0)
                self.sim.eval()
                self.dump_to_trace(self.sim.vcd_trace, self.time)
                self._clk(1)
                self.sim.eval()
                self.dump_to_trace(self.sim.vcd_trace, self.time + 5)
                self.time += 10
                for x in self.tick_callbacks:
                    x()
        else:
            for i in range(n):
                self.sim.eval()
                self.dump_to_trace(self.sim.vcd_trace, self.time - 5)
                self._clk(0)
                self.sim.eval()
                self.dump_to_trace(self.sim.vcd_trace, self.time)
                self._clk(1)
                self.sim.eval()
                self.dump_to_trace(self.sim.vcd_trace, self.time + 5)
                self.time += 10
                cb()
                for x in self.tick_callbacks:
                    x()

        self.sim.flush_vcd_trace()
