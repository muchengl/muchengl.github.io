---
title: first-blog Test
date: 2022-11-13 16:10:26
tags:
---

![1](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/1.jpeg)

# Spring学习笔记（1）

### 1.依赖注入，控制反转的理解

### 2.Spring程序结构

- 实体类（pojo）
```java
package com.liu.pojo;
public class Hello {
    private String str;
    public void setStr(String str) {
        this.str = str;
    }
    public String getStr() {
        return str;
    }
    public String toString() {
        return "Hello{" +
                "str='" + str + '\'' +
                '}';
    }
}
```
- 配置文件
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="user" class="com.liu.pojo.Hello">
        <property name="str" value="123"/>
    </bean>
</beans>
```
- 测试类
```java
public class Test {
    public static void main(String[] args) {
        //获取Spring的上下文对象
        ApplicationContext context = new ClassPathXmlApplicationContext("beans.xml");

        Hello hello=(Hello)context.getBean("hello");
        System.out.println(hello.toString());
    }
}
```
### 3.set注入方法（di）
- 实体类
```java
public class Students {
    private String name;
    private Address address;
    private String[] book;
    private List<String> hobby;
    private Map<String,String> card;
    private Set<String> game;
    private Properties info;
    private String wife;

}
```
```java
public class Address {
    private String address;
}
```
- 配置文件
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean id="address" class="com.liu.pojo.Address"/>
    <bean id="student" class="com.liu.pojo.Students">
<!--        普通值注入-->
        <property name="name" value="刘瀚中"/>
<!--        bean注入，使用ref-->
        <property name="address" ref="address"/>
<!--              数组注入-->
        <property name="book">
            <array>
                <value>傲慢与偏见</value>
                <value>呼啸山庄</value>
                <value>瓦尔登湖</value>
            </array>
        </property>
<!--              列表注入-->
        <property name="hobby">
            <list>
                <value>傲慢与偏见</value>
                <value>呼啸山庄</value>
                <value>瓦尔登湖</value>
            </list>
        </property>
<!--              map注入-->
        <property name="card">
            <map>
                <entry key="饭卡" value="123456"/>
                <entry key="工资卡" value="123456"/>
            </map>
        </property>
<!--              集合注入-->
        <property name="game">
            <set>
               <value type="java.lang.String">吃鸡</value>
                <value type="java.lang.String">lol</value>
            </set>
        </property>
<!--        properties注入-->
        <property name="info">
            <props>
                <prop key="administrator">administrator@example.org</prop>
                <prop key="support">support@example.org</prop>
                <prop key="development">development@example.org</prop>
            </props>
        </property>
<!--        null注入-->
        <property name="wife">
            <null></null>
        </property>

    </bean>
</beans>
```
### 4.自动装配（autowiring）
自动装配首先会根据name寻找对象，
```java
public class People {
    @Value("1")
    private int age;
    @Autowired
    private Cat cat;
    @Autowired
    @Qualifier(value = "dog1")//若dog对象不唯一，需设置类名
    private Dog dog;
    private String name;
}
```
```java
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        https://www.springframework.org/schema/context/spring-context.xsd">
    <context:annotation-config/>
    <bean id="cat" class="com.liu.pojo.Cat"/>
    <bean id="dog1" class="com.liu.pojo.Dog"/>
    <bean id="dog2" class="com.liu.pojo.Dog"/>
    <bean id="people" class="com.liu.pojo.People" autowire="byName"/>
</beans>
```
### 5.注解编程
- 配置文件（xml）与注解并存
  - dao层：@Repository
  - pojo层：@Component
  - service：@Service
  - Controller层：@Controller
```java
@Component //等价于<bean id="user" class="com.liu.pojo.User"/>
@Scope("singleton")//单例，prototype原型模式
public class User {
    @Value("lhz")
    private String name;
}
```
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        https://www.springframework.org/schema/context/spring-context.xsd">

    <context:annotation-config/>
    <context:component-scan base-package="com.liu"/>
<!--    扫描包下的注解-->

</beans>
```

### 6.代理模式

### 7.面向切面编程(aop)
面向切面编程，是在不改变原有代码的基础上，增强代码的功能。Spring-aop有三种实现方式。
- 方法一：Spring原生API接口实现
```xml
<bean id="userService" class="com.liu.service.UserServiceImpl"/>
<bean id="afterLog" class="com.liu.log.AfterLog"/>
<bean id="beforeLog" class="com.liu.log.BeforeLog"/>
<!--方式1:原生Spring的API接口-->
<aop:config>
    <aop:pointcut id="pointcut" expression="execution(* com.liu.service.UserServiceImpl.*(..))"/>
    <aop:advisor advice-ref="afterLog" pointcut-ref="pointcut"/>
    <aop:advisor advice-ref="beforeLog" pointcut-ref="pointcut"/>
</aop:config>
```
在一个包下建立以下两个类，分别作为执行前和执行后
```java
public class BeforeLog implements MethodBeforeAdvice {
    public void before(Method method, Object[] objects, Object target) throws Throwable {
        System.out.println(target.getClass().getName()+"的"+method.getName()+"被执行了");
    }
}

```
```java
public class AfterLog implements AfterReturningAdvice {
    public void afterReturning(Object o, Method method, Object[] objects, Object o1) throws Throwable {
        System.out.println("执行了"+method.getName()+"方法，返回结果为："+o);
    }
}
```
- 方法二：使用自定义类
定义一个DiyPointCut类，在里面写after和before方法
```xml
    <!--方式2：自定义类-->
    <bean id="diy" class="com.liu.diy.DiyPointCut"/>
    <aop:config>
        <!--自定义切面-->
        <aop:aspect ref="diy">
            <!--切点-->
            <aop:pointcut id="pointcut" expression="execution(* com.liu.service.UserServiceImpl.*(..))"/>
            <!--通知-->
            <aop:before method="before" pointcut-ref="pointcut"/>
            <aop:after method="after" pointcut-ref="pointcut"/>
        </aop:aspect>
    </aop:config>
```
```java
public class DiyPointCut {
    public void after(){
        System.out.println("=========方法执行后========");
    }
    public void before(){
        System.out.println("=========方法执行前========");
    }
}
```
- 方法三：使用注解
需在xml文件中开启注解
```xml
<!--方式3-->
    <aop:aspectj-autoproxy/><!--开启注解-->
    <bean id="annotationPointCut" class="com.liu.diy.AnnotationPointCut"/>
```
```java
@Aspect//标记为切面
public class AnnotationPointCut {
    @Before("execution(* com.liu.service.UserServiceImpl.*(..))")
    public void before(){
        System.out.println("===方法执行前===");
    }
    @After("execution(* com.liu.service.UserServiceImpl.*(..))")
    public void after(){
        System.out.println("===方法执行后===");
    }
}
```
### 8.Spring和MyBatis整合
需使用maven导入相应的jar包
```xml
<dependencies>

        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.18</version>
        </dependency>

        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.5.3</version>

        </dependency>
        <!--测试-->
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
        </dependency>
        <!--注解-->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.18.10</version>
        </dependency>
<!--        spring依赖-->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>5.2.3.RELEASE</version>
        </dependency>
        <!--        Spring操控数据库-->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-jdbc</artifactId>
            <version>5.2.3.RELEASE</version>
        </dependency>
<!--        aop织入包-->
        <dependency>
            <groupId>org.aspectj</groupId>
            <artifactId>aspectjweaver</artifactId>
            <version>1.9.5</version>
        </dependency>

        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis-spring</artifactId>
            <version>2.0.3</version>
        </dependency>

    </dependencies>
```
Spring-Mybatis使用Spring将Mybatis的配置整合，可以选择在原来的MyBatis-config文件中配置一些简单的Mapper注册和引用别名，在Spring-dao.xml文件中写各种配置，最后在applicationContext.xml文件中注册各个类。与Mybatis不同，Spring-Mybatis只能获得SqlSessionFactoryBean和SqlSessionTemplate。Spring-Mybatis有两种实现方式。
- 第一种方式

首先需要建立实体类，并建立接口和对应的xml文件，然后开始配置xml文件
MyBatis-config.xml
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
<!--    引用别名-->
    <typeAliases>
        <package name="com.liu.pojo"/>
    </typeAliases>
    <mappers>
        <mapper resource="com/liu/dao/StudentsMapper.xml"/>
    </mappers>
</configuration>
```
Spring-dao.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">
<!--    datasource数据源-->
    <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
        <property name="driverClassName" value="com.mysql.cj.jdbc.Driver"/>
        <property name="url" value="jdbc:mysql://localhost:3306/mybatis?useSSl=true&amp;useUnicode=true&amp;characterEncoding=utf-8"/>
        <property name="username" value="root"/>
        <property name="password" value="123456"/>
    </bean>

<!--    sqlSessionFactory-->
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="dataSource"/>
<!--        绑定MyBatis配置文件-->
        <property name="configLocation" value="classpath:mybatis-config.xml"/>
        <!-- 注册接口 -->
        <property name="mapperLocations" value="classpath:com/liu/dao/StudentsMapper.xml"/>
    </bean>

    <bean id="sqlSession" class="org.mybatis.spring.SqlSessionTemplate">
        <constructor-arg index="0" ref="sqlSessionFactory"/>
    </bean>
</beans>

```
applicationContext.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">

    <import resource="spring-dao.xml"/>
    <bean id="studentsMapper" class="com.liu.dao.StudentsMapperImpl">
        <property name="sqlSession" ref="sqlSession"/>
    </bean>
</beans>
```

在完成xml配置之后，一般可以建立一个接口的实现类，并在这个类获取sqlSession,在application文件中注册这个类，并将sqlSession通过set注入这个类

```java
public class StudentsMapperImpl implements StudentsMapper {
    private SqlSessionTemplate sqlSession;

    public void setSqlSession(SqlSessionTemplate sqlSession) {
        this.sqlSession = sqlSession;
    }

    public List<Students> getStudents() {
        StudentsMapper studentsMapper=sqlSession.getMapper(StudentsMapper.class);
        return studentsMapper.getStudents();
    }

}
```

最后就可以进行测试

```java
public void Test2(){
        ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");//Spring配置文件
        StudentsMapper studentsMapper=context.getBean("studentsMapper1",StudentsMapper.class);//接口，获取实现类
        List<Students> list=studentsMapper.getStudents();
        for (Students students : list) {
            System.out.println(students);
        }
    }
```

- 方法二
向接口的实现类注入sqlSeeeionFectory，该实现类需继承SqlSessionDaoSupport

```java
public class StudentsMapperImpl2 extends SqlSessionDaoSupport implements StudentsMapper {

    public List<Students> getStudents() {
        StudentsMapper studentsMapper=getSqlSession().getMapper(StudentsMapper.class);//此处使用getSqlSession()
        return studentsMapper.getStudents();
    }
}
```
注入sqlSessionFactory
```java
<bean id="studentsMapper2" class="com.liu.dao.StudentsMapperImpl2">
        <property name="sqlSessionFactory" ref="sqlSessionFactory"/>
    </bean>

```
