module PictureBooksHelper
  def auto_sort_contents(book_id)                                                
    seqs = []                                                                    
    BookContent.where(book_id: book_id).each do |content|                        
      serial_sn = content.name.scan(/\d/).join                                   
      if serial_sn.blank?                                                        
        serial_sn = 0                                                            
      else                                                                       
        serial_sn = serial_sn.to_i                                               
      end                                                                        
      seqs << {id: content.id, serial_sn: serial_sn}                             
    end                                                                          
                                                                                 
    seqs = seqs.sort{|x,y| x[:serial_sn] <=> y[:serial_sn]}                      
    seqs.each_with_index do |x, idx|                                             
      c = BookContent.find_by_id x[:id]                                          
      c.update(sn: idx + 1)                                                      
    end                                                                          
                                                                                 
    identify_time(book_id)                                                       
  end

  def identify_time(book_id)                                                     
    book = Book.find_by_id book_id                                                                                        
    lines = book.time_line.split("\n")                                           
                                                                                 
    lines.each do |line|                                                         
      arrs = line.split(",")                                                     
      next if arrs.blank?                                                        
      next if arrs.size != 2                                                     
      name = arrs[0]                                                             
                                                                                 
      ts = arrs[1].split("-")                                                    
      next if ts.size != 2                                                       
                                                                                 
      content = BookContent.find_by(book_id: book_id, name: name)                
      next if content.nil?                                                       
      content.update(start_at: ts[0], deal_at: ts[1])
    end
  end
end
