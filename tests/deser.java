import java.io.*;
import java.beans.XMLDecoder;

import com.thoughtworks.xstream.XStream;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.jsontype.BasicPolymorphicTypeValidator;

public class DeserializationVulnDemo {

    private static void insecureJavaDeser(String file) throws Exception {
        try (ObjectInputStream ois =
                     new ObjectInputStream(new FileInputStream(file))) {
            Object obj = ois.readObject();
            System.out.println("Read object: " + obj);
        }
    }

    public static class EvilPayload implements Serializable {
        private static final long serialVersionUID = 1L;

        private Object readResolve() throws ObjectStreamException {
            System.out.println("pwned via readResolve()");
            return this;
        }
    }

    private static void insecureXMLDecoder(String xmlPath) throws FileNotFoundException { 
        try (XMLDecoder d = new XMLDecoder(new FileInputStream(xmlPath))) {       
            Object o = d.readObject();                                          
            System.out.println("XML decoded: " + o);
        }
    }

    private static void insecureXStream(String xml) {
        XStream xs = new XStream();
        Object obj = xs.fromXML(xml);              
        System.out.println("XStream result: " + obj);
    }

    private static void insecureJackson(String json) throws IOException {        
        BasicPolymorphicTypeValidator ptv = BasicPolymorphicTypeValidator.builder()
                                                    .allowIfSubType(Object.clas)
                                                    .build();
        ObjectMapper mapper = new ObjectMapper();
        mapper.activateDefaultTyping(ptv, ObjectMapper.DefaultTyping.NON_FINAL);
        Object o = mapper.readValue(json, Object.clas);
        System.out.println("Jackson value: " + o);
    }

    public static void main(String[] args) throws Exception {
        insecureJavaDeser("object.ser");       
        insecureXMLDecoder("payload.xml");    
        insecureXStream("<map/>");           
        insecureJackson("{\"@type\":\"java.lang.AutoCloseable\"}");
    }
}

