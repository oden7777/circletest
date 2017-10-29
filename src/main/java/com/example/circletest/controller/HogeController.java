package com.example.circletest.controller;

import com.example.circletest.service.HogeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 * Created by suyamayutaro on 2017/10/29.
 */
@RestController
@RequestMapping("/")
public class HogeController {
	@Autowired
	HogeService hogeService;

	@RequestMapping(value ="/hoge", method = RequestMethod.GET)
	public void create()
	{
		hogeService.create();
	}
}
