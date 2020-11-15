# Non-interactive UART (8/N/1) simulator
import queue

class UARTSim:

    """
        Setup UART. `dut_rx` or `dut_tx` may be None
    """
    def __init__(self, dut_rx, dut_tx, clock_freq, baud):
        self.tx = dut_rx
        self.rx = dut_tx

        self.clks_per_baud = int(clock_freq / baud)
        self.clks_per_1_5_baud = int(1.5 * self.clks_per_baud)

        self.send_queue = queue.Queue()
        self.recv_queue = queue.Queue()

        self.send_state = 0 # 0 = start, ...bits, 9 = end
        self.send_data = None
        self.send_ctr = 0

        self.recv_state = 0 # 0 = idle, ...bits, 9 = end
        self.recv_data = None
        self.recv_ctr = 0

        if self.tx is not None:
            self.tx(1)

    """
        Updates the UART
        Return a byte if it was recieved, else None
    """
    def update(self):
        if self.tx is not None:
            if self.send_data is None and not self.send_queue.empty():
                self.send_data = [int(bit) for bit in format(self.send_queue.get(), "08b")][::-1]
                self.send_ctr = self.clks_per_baud
                self.send_state = 0
                self.tx(0)

            if self.send_data is not None:
                if self.send_ctr == 0:
                    if self.send_state == 9:
                        self.send_data = None
                        self.tx(1)
                    else:
                        self.send_state += 1
                        if self.send_state == 9:
                            self.tx(1)
                        else:
                            self.tx(self.send_data[self.send_state - 1])

                        self.send_ctr = self.clks_per_baud

                self.send_ctr -= 1

        recv_byte = None

        if self.rx is not None:
            if self.recv_state == 0:
                if self.rx() == 0:
                    self.recv_data = []
                    self.recv_state = 1
                    self.recv_ctr = self.clks_per_1_5_baud

            elif self.recv_ctr == 0:
                if self.recv_state == 9:
                    if self.rx() == 1:
                        recv_byte = int("".join(self.recv_data[::-1]), 2)
                        self.recv_queue.put(recv_byte)
                    else:
                        print("UARTSim: INVALID END BIT")

                    self.recv_state = 0

                else:
                    self.recv_state += 1
                    self.recv_data.append(str(self.rx()))
                    self.recv_ctr = self.clks_per_baud

            else:
                self.recv_ctr -= 1

        return recv_byte

    def send(self, byte):
        self.send_queue.put(byte)

    def send_all(self, byte_list):
        for byte in byte_list:
            self.send(byte)

    """
        Gets the last unread recieved byte (in FIFO order)
        If `n` specified, attempts to get `n` bytes, else returns None

    """
    def get_recv_data(self, n=1):
        try:
            if n == 1:
                return self.recv_queue.get(block=False)
            else:
                arr = []
                for i in range(n):
                    arr.append(self.recv_queue.get(block=False))

                return arr
        except:
            return None

    """
        Gets the number of available bytes
    """
    def get_recv_len(self):
        return self.recv_queue.qsize()

