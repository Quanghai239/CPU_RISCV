RISC-V là bộ tập lệnh mã nguồn mở đầu tiên trên thế giới đạt được quy mô công nghiệp. Chỉ trong vòng 14 năm từ khi ra đời tại Berkeley, hiện nay đã có hơn 10 tỷ lõi RISC-V được xuất xưởng và được hàng loạt “ông lớn” như Google, NVIDIA, Alibaba tin dùng.

Khác hẳn với ARM hay x86 phải trả phí bản quyền rất cao và bị giới hạn tùy biến, RISC-V hoàn toàn miễn phí và cho phép chúng ta tự do thiết kế lại CPU theo ý mình.
Sơ đồ khối hệ thống
<img width="887" height="409" alt="image" src="https://github.com/user-attachments/assets/0db6bbd0-c513-4d7e-a4f3-4325c65f6d6f" />
Đồ án trình bày về thiết kế một bộ xử lý ngắt trong kiến trúc RISC-V. Bộ xử lý  ngắt này có nhiệm vụ tiếp nhận và xử lý các yêu cầu ngắt từ nhiều nguồn khác nhau trong hệ thống MCU, bao gồm ngắt từ bộ đếm thời gian (timer) và các thiết bị ngoại vi như UART. 

Trong thiết kế này, CPU RISC-V 32I được triển khai với bộ xử lý ngắt cơ bản và sử dụng PLIC (Platform-Level Interrupt Controller) để quản lý các ngắt từ thiết bị ngoại vi. Tuy nhiên, ngắt từ bộ đếm thời gian (timer) không được kết nối thông qua PLIC mà được đưa trực tiếp 
vào CPU dưới dạng một tín hiệu ngắt riêng biệt. Cách tiếp cận này đơn giản hóa logic xử lý ngắt định kỳ, cho phép CPU phản hồi nhanh chóng các sự kiện thời gian thực mà không cần thông qua cơ chế phân ưu tiên của PLIC.

Bộ đếm thời gian (timer) được thiết kế để tạo ra các tín hiệu ngắt định kỳ. Khi đạt đến giá trị đếm giới hạn, timer sẽ gửi tín hiệu ngắt trực tiếp đến CPU. CPU sẽ nhận và xử lý ngắt này nhằm phục vụ các tác vụ định kỳ như cập nhật thời gian hệ thống, kiểm tra thời gian timeout, hoặc thực hiện các nhiệm vụ thời gian thực khác. 

Đối với các thiết bị ngoại vi như UART hay GPIO, PLIC được sử dụng để tiếp nhận các tín hiệu ngắt, phân loại và gán mức ưu tiên trước khi chuyển yêu cầu ngắt đến 
CPU. Việc sử dụng PLIC giúp hệ thống dễ dàng mở rộng và hỗ trợ nhiều nguồn ngắt ngoại vi một cách hiệu quả.
